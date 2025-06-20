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
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                if authViewModel.shouldShowOnboarding {
                    OnboardingView(isPresented: .constant(true))
                        .environmentObject(authViewModel)
                        .onReceive(NotificationCenter.default.publisher(for: .init("OnboardingCompleted"))) { _ in
                            authViewModel.completeOnboarding()
                        }
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
            .environmentObject(ThemeManager())
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
