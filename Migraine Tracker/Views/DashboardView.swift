import SwiftUI
import CoreLocation

// Extension für CLLocationCoordinate2D Equatable
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

// Weather Data Model
struct WeatherData {
    let temperature: Double
    let uvIndex: Int
    let humidity: Int
    let airPressure: Int
    let location: String // Wird mit dem Stadtnamen gefüllt
}

// Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var currentCity: String = "Unknown" // Startwert
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // kCLLocationAccuracyKilometer ist oft ausreichend und akkuschonender
        // Berechtigung wird angefordert, wenn das Objekt erstellt wird
        // requestLocationPermission() // Kann hier oder expliziter in der View aufgerufen werden
    }

    func requestLocationPermission() {
        // Fordert die Berechtigung an, wenn sie noch nicht erteilt wurde
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation() // Standort direkt abfragen, wenn schon erlaubt
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Nur aktualisieren, wenn es eine signifikante Änderung gibt oder currentLocation noch nil ist
        if currentLocation == nil || currentLocation!.latitude != location.coordinate.latitude || currentLocation!.longitude != location.coordinate.longitude {
            currentLocation = location.coordinate
            
            // Reverse Geocoding für Stadtname
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Reverse geocoding error: \(error.localizedDescription)")
                        self?.currentCity = "City N/A" // Fehler beim Geocoding
                        return
                    }
                    if let placemark = placemarks?.first {
                        self?.currentCity = placemark.locality ?? placemark.administrativeArea ?? "Unknown City"
                    } else {
                        self?.currentCity = "City not found"
                    }
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        // Hier könnten Sie dem Nutzer eine Fehlermeldung anzeigen
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access granted.")
            locationManager.startUpdatingLocation() // Wichtig: Standort-Updates starten!
        case .denied:
            print("Location access denied.")
            currentCity = "Location Denied"
            currentLocation = nil // Standort zurücksetzen
            // Hier könnten Sie den Nutzer informieren, dass die App ohne Standort nicht optimal funktioniert
        case .restricted:
            print("Location access restricted.")
            currentCity = "Location Restricted"
            currentLocation = nil
        case .notDetermined:
            print("Location access not determined yet.")
            // requestLocationPermission() // Erneut anfordern oder warten, bis der Nutzer es in den Einstellungen ändert
        default:
            break
        }
    }
}

// Weather Service mit OpenMeteo API
class WeatherService: ObservableObject {
    @Published var weatherData: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?

    func fetchWeatherData(latitude: Double = 52.5200, longitude: Double = 13.4050, cityName: String = "Berlin") {
        isLoading = true
        errorMessage = nil
        weatherData = nil

        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,relative_humidity_2m,surface_pressure,uv_index&timezone=auto"

        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL for weather API"
            self.isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    self.errorMessage = "Weather API Error: Status Code \((response as? HTTPURLResponse)?.statusCode ?? 0)"
                    return
                }
                guard let data = data else {
                    self.errorMessage = "No data received from weather API"
                    return
                }
                do {
                    let weatherResponse = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
                    self.weatherData = WeatherData(
                        temperature: weatherResponse.current.temperature_2m,
                        uvIndex: Int(weatherResponse.current.uv_index ?? 0),
                        humidity: Int(weatherResponse.current.relative_humidity_2m),
                        airPressure: Int(weatherResponse.current.surface_pressure),
                        location: cityName
                    )
                    self.lastUpdated = Date()
                    self.errorMessage = nil
                } catch {
                    self.errorMessage = "Failed to decode weather data: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
}

// OpenMeteo Response Models (bleiben gleich)
struct OpenMeteoResponse: Codable {
    let current: CurrentWeather
}

struct CurrentWeather: Codable {
    let temperature_2m: Double
    let relative_humidity_2m: Double
    let surface_pressure: Double
    let uv_index: Double?
}

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var weatherService = WeatherService()
    @State private var showRiskInfo = false

    // Sample data für andere Trigger
    let topTriggers = [
        (name: "Weather", percentage: 90),
        (name: "Noise", percentage: 85),
        (name: "Sleep", percentage: 63)
    ]
    
    // Berechne Risiko basierend auf Wetterdaten
    private var riskLevel: Int {
        guard let weather = weatherService.weatherData else {
            return 0 // Standard-Risiko wenn keine Daten verfügbar
        }
        
        var risk = 0
        
        // Temperatur-Risiko (extreme Temperaturen erhöhen Risiko)
        if weather.temperature < 5 || weather.temperature > 25 {
            risk += 2
        } else if weather.temperature < 10 || weather.temperature > 20 {
            risk += 1
        }
        
        // UV-Index Risiko (hoher UV-Index kann Migräne triggern)
        if weather.uvIndex >= 8 {
            risk += 2
        } else if weather.uvIndex >= 6 {
            risk += 1
        }
        
        // Luftfeuchtigkeit (sehr hohe oder niedrige Werte)
        if weather.humidity < 30 || weather.humidity > 80 {
            risk += 1
        }
        
        // Luftdruck (niedrige Werte können Migräne triggern)
        if weather.airPressure < 1005 || weather.airPressure > 1025  {
            risk += 2
        } else if weather.airPressure < 1010 || weather.airPressure > 1020 {
            risk += 1
        }
        
        // Stelle sicher, dass Risiko zwischen 0 und 5 liegt
        return min(max(risk, 0), 5)
    }
    
    private var tipOfTheDay: String {
        switch riskLevel {
        case 0:
            return "Great news! Your migraine risk is very low today. This is a perfect day to engage in your favorite activities and enjoy life to the fullest."
        case 1:
            return "Your migraine risk is low today. Keep up your healthy habits and stay hydrated. It's a good day to tackle any tasks you've been putting off."
        case 2:
            return "Your migraine risk is slightly elevated today. Consider avoiding known triggers and maintain a regular sleep schedule. Take breaks when needed."
        case 3:
            return "Today's migraine risk is moderate. Try to keep your environment quiet, stay well-rested, and avoid stress. Consider having your medication ready."
        case 4:
            return "Your migraine risk is high today. Take extra precautions: avoid bright lights, loud noises, and stressful situations. Plan a calm, relaxing day."
        case 5:
            return "Your migraine risk is very high today. Consider staying in a quiet, dark environment and avoid all known triggers. Keep medication close and rest as much as possible."
        default:
            return "Monitor your symptoms and take care of yourself today."
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        formatter.locale = Locale(identifier: "en_EN")
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Today's Risk
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Today's Risk")
                                .font(.headline)
                            
                            Text(dateFormatter.string(from: Date()))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                showRiskInfo = true
                            }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                            }
                            
                            Spacer()
                        }
                        
                        HStack(spacing: 8) {
                            ForEach(0..<5, id: \.self) { index in
                                Circle()
                                    .fill(index < riskLevel ? Color.orange : Color.gray.opacity(0.3))
                                    .frame(width: 20, height: 20)
                            }
                            
                            Spacer()
                            
                            Text("\(riskLevel)/5")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Top Triggers
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Top Triggers")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(topTriggers.indices, id: \.self) { index in
                                HStack {
                                    Text("\(index + 1). \(topTriggers[index].name)")
                                    Spacer()
                                    Text("\(topTriggers[index].percentage)%")
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Tip of the Day
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tip of the Day")
                            .font(.headline)
                        
                        Text(tipOfTheDay)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Data for today - Wetterdaten aus Münster
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Data for today (Münster)")
                                .font(.headline)
                            
                            Spacer()
                            
                            if let lastUpdated = weatherService.lastUpdated {
                                Text("Last updated: \(lastUpdated, formatter: timeFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Button(action: {
                                loadMuensterWeather()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(weatherService.isLoading ? .gray : .blue)
                                    .rotationEffect(.degrees(weatherService.isLoading ? 360 : 0))
                                    .animation(weatherService.isLoading ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: weatherService.isLoading)
                            }
                            .disabled(weatherService.isLoading)
                        }
                        
                        if weatherService.isLoading {
                            ProgressView("Loading weather data...")
                                .font(.caption)
                        } else if let error = weatherService.errorMessage {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Error: \(error)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(5)
                                
                                Button("Retry") {
                                    loadMuensterWeather()
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        } else if let weather = weatherService.weatherData {
                            HStack(spacing: 20) {
                                // Temperature
                                let tempRisk = temperatureRisk(weather.temperature)
                                VStack(alignment: .leading) {
                                    Text("Temperature")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(Int(weather.temperature))°C")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(tempRisk == 2 ? .red : (tempRisk == 1 ? .orange : .primary))
                                }
                                
                                // UV Index
                                let uvRisk = uvIndexRisk(weather.uvIndex)
                                VStack(alignment: .leading) {
                                    Text("UV-Index")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(weather.uvIndex)")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(uvRisk == 2 ? .red : (uvRisk == 1 ? .orange : .primary))
                                }
                                
                                // Humidity
                                let humidityRisk = humidityRisk(weather.humidity)
                                VStack(alignment: .leading) {
                                    Text("Humidity")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(weather.humidity)%")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(humidityRisk == 2 ? .red : (humidityRisk == 1 ? .orange : .primary))
                                }
                                
                                // Air Pressure
                                let pressureRisk = airPressureRisk(weather.airPressure)
                                VStack(alignment: .leading) {
                                    Text("Air Pressure")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(weather.airPressure) hPa")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(pressureRisk == 2 ? .red : (pressureRisk == 1 ? .orange : .primary))
                                }
                            }
                        } else {
                            VStack(spacing: 15) {
                                HStack(spacing: 20) {
                                    VStack(alignment: .leading) {
                                        Text("Temperature")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text("--°C")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text("UV-Index")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text("--")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text("Humidity")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text("--%")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text("Air Pressure")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text("---- hPa")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .onAppear {
                loadMuensterWeather()
            }
            .sheet(isPresented: $showRiskInfo) {
                RiskCalculationInfoView()
            }
        }
    }
    
    private func loadMuensterWeather() {
        // Münster Koordinaten: 51.9607° N, 7.6261° E
        weatherService.fetchWeatherData(
            latitude: 51.9607,
            longitude: 7.6261,
            cityName: "Münster"
        )
    }
    
    // Risk calculation helper functions
    private func temperatureRisk(_ temperature: Double) -> Int {
        if temperature < 5 || temperature > 25 {
            return 2
        } else if temperature < 10 || temperature > 20 {
            return 1
        }
        return 0
    }
    
    private func uvIndexRisk(_ uvIndex: Int) -> Int {
        if uvIndex >= 8 {
            return 2
        } else if uvIndex >= 6 {
            return 1
        }
        return 0
    }
    
    private func humidityRisk(_ humidity: Int) -> Int {
        if humidity < 30 || humidity > 80 {
            return 1
        }
        return 0
    }
    
    private func airPressureRisk(_ pressure: Int) -> Int {
        if pressure < 1005 || pressure > 1025 {
            return 2
        } else if pressure < 1010 || pressure > 1020 {
            return 1
        }
        return 0
    }
}

struct RiskCalculationInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Risk Calculation")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Temperature Risk")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("• Extreme temperatures (<5°C or >25°C): +2 risk points")
                        Text("• Moderate temperatures (<10°C or >20°C): +1 risk point")
                        Text("• Comfortable temperatures (10-20°C): No additional risk")
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("UV Index Risk")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("• Very high UV (≥8): +2 risk points")
                        Text("• High UV (≥6): +1 risk point")
                        Text("• Moderate UV (<6): No additional risk")
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Humidity Risk")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("• Very low (<30%) or very high (>80%): +1 risk point")
                        Text("• Comfortable humidity (30-80%): No additional risk")
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Air Pressure Risk")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("• Low pressure (<1010 hPa): +2 risk points")
                        Text("• Slightly low pressure (<1015 hPa): +1 risk point")
                        Text("• Normal pressure (≥1015 hPa): No additional risk")
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Risk Levels")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("• 0-1: Low risk")
                        Text("• 2-3: Moderate risk")
                        Text("• 4-5: High risk")
                    }
                    
                    Text("The total risk score is calculated by adding all individual risk factors and is capped between 0 and 5.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// Preview (bleibt gleich)
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(AuthViewModel())
    }
}
