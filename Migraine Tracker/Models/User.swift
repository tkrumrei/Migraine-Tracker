// User.swift
import Foundation

struct MigraineUser: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var password: String = ""
    var migraineType: String = ""
    var migraineFrequency: String = ""
    
    init(id: UUID = UUID(), name: String, email: String, password: String = "", migraineType: String = "", migraineFrequency: String = "") {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.migraineType = migraineType
        self.migraineFrequency = migraineFrequency
    }
}
