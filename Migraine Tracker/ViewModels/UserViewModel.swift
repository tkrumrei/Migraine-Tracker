import Foundation
import SwiftUI

class UserViewModel: ObservableObject {
    @Published var currentUser: AppUser?
    
    init() {
        // Initialization code if needed
    }
    
    func updateUser(_ user: AppUser) {
        self.currentUser = user
    }
}
