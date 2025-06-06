//
//  ContentView.swift
//  Migraine Tracker
//
//  Created by Tim Lehmann on 06.06.25.
//

import SwiftUI

// Main app content view
struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                if authViewModel.currentUser?.migraineType.isEmpty ?? true {
                    OnboardingView(isPresented: $showOnboarding)
                } else {
                    MainTabView()
                }
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
