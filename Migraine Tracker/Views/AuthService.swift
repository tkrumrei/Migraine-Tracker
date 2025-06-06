// AuthService.swift
import Foundation
import SwiftUI

class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: MigraineUser?
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        isAuthenticated = userDefaults.bool(forKey: "isLoggedIn")
        if isAuthenticated {
            loadCurrentUser()
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        // Test-Login
        if email == "test@30five.com" && password == "test123" {
            let user = MigraineUser(name: "Test User", email: email, password: password)
            self.currentUser = user
            self.isAuthenticated = true
            userDefaults.set(true, forKey: "isLoggedIn")
            userDefaults.set(email, forKey: "userEmail")
            completion(true, nil)
        } else {
            completion(false, "Invalid credentials")
        }
    }
    
    func register(name: String, email: String, password: String, migraineType: String, migraineFrequency: String, completion: @escaping (Bool, String?) -> Void) {
        // Simuliere Registrierung
        let user = MigraineUser(
            name: name,
            email: email,
            password: password,
            migraineType: migraineType,
            migraineFrequency: migraineFrequency
        )
        self.currentUser = user
        self.isAuthenticated = true
        userDefaults.set(true, forKey: "isLoggedIn")
        userDefaults.set(email, forKey: "userEmail")
        userDefaults.set(name, forKey: "userName")
        completion(true, nil)
    }
    
    func logout() {
        isAuthenticated = false
        currentUser = nil
        userDefaults.set(false, forKey: "isLoggedIn")
        userDefaults.removeObject(forKey: "userEmail")
    }
    
    private func loadCurrentUser() {
        if let email = userDefaults.string(forKey: "userEmail") {
            let name = userDefaults.string(forKey: "userName") ?? "User"
            currentUser = MigraineUser(name: name, email: email)
        }
    }
}
