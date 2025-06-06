import Foundation
import SwiftUI

// Import User model
struct AppUser: Codable {
    var name: String
    var email: String
    var password: String // Note: In a real app, this should be encrypted
    var migraineType: String
    var migraineFrequency: String
}

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: AppUser?
    
    init() {
        // Check if user is already logged in
        if let savedUser = UserDefaults.standard.data(forKey: "savedUser"),
           let user = try? JSONDecoder().decode(AppUser.self, from: savedUser) {
            self.currentUser = user
            self.isLoggedIn = true
        }
    }
    
    func login(email: String, password: String, rememberMe: Bool) -> Bool {
        // In a real app, this would check against a database or API
        // For now, we'll use a test user
        if email == "test@30five.com" && password == "test123" {
            let user = AppUser(name: "Test User", email: email, password: password, migraineType: "", migraineFrequency: "0")
            self.currentUser = user
            self.isLoggedIn = true
            
            if rememberMe {
                if let encoded = try? JSONEncoder().encode(user) {
                    UserDefaults.standard.set(encoded, forKey: "savedUser")
                }
            }
            return true
        }
        return false
    }
    
    func logout() {
        self.currentUser = nil
        self.isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: "savedUser")
    }
    
    func register(name: String, email: String, password: String) -> Bool {
        // In a real app, this would create a new user in a database or API
        // For now, we'll just create a test user
        let user = AppUser(name: name, email: email, password: password, migraineType: "", migraineFrequency: "0")
        self.currentUser = user
        self.isLoggedIn = true
        
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "savedUser")
        }
        return true
    }
    
    func updateUserProfile(migraineType: String, migraineFrequency: String) {
        guard var currentUser = self.currentUser else { return }
        currentUser.migraineType = migraineType
        currentUser.migraineFrequency = migraineFrequency
        self.currentUser = currentUser
        
        if let encoded = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(encoded, forKey: "savedUser")
        }
    }
}
