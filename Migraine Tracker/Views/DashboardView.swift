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

    // Sample data
    let riskLevel = 3
    let topTriggers = [
        (name: "Weather", percentage: 90),
        (name: "Noise", percentage: 85),
        (name: "Sleep", percentage: 63)
    ]
    
    let tipOfTheDay = "Today's migraine risk is slightly elevated. Try to keep your environment quiet and stay well-rested."
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Risk Level Card
                    VStack(spacing: 15) {
                        Text("Today's Risk")
                            .font(.headline)
                        
                        // Risk visualization
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { level in
                                Circle()
                                    .fill(level <= riskLevel ? Color.orange : Color.gray.opacity(0.3))
                                    .frame(width: 12, height: 12)
                            }
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
                        Text("Tip of the day")
                            .font(.headline)
                        
                        Text(tipOfTheDay)
                            .font(.subheadline)
                            .foregroundColor(.gray)
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
                                VStack(alignment: .leading) {
                                    Text("Temperature")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(Int(weather.temperature))°C")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("UV-Index")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(weather.uvIndex)")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Humidity")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(weather.humidity)%")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Air Pressure")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(weather.airPressure) hPa")
                                        .font(.title3)
                                        .fontWeight(.semibold)
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
}

// Preview (bleibt gleich)
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(AuthViewModel())
    }
}
