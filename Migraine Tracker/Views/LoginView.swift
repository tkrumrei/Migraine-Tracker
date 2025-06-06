import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = "test@30five.com"
    @State private var password = "test123"
    @State private var rememberMe = false
    @State private var isShowingRegistration = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .onAppear {
                        print("ℹ️ Attempting to load image named: Logo")
                    }
                
                Text("Migraine Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Toggle("Remember me", isOn: $rememberMe)
                        .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                    
                    Button(action: {
                        let success = authViewModel.login(email: email, password: password, rememberMe: rememberMe)
                        if !success {
                            alertMessage = "Invalid email or password"
                            showAlert = true
                        }
                    }) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.cyan)
                            .cornerRadius(10)
                    }
                    
                    Button("Don't have an account? Register") {
                        isShowingRegistration = true
                    }
                    .foregroundColor(.cyan)
                }
                .padding()
                .sheet(isPresented: $isShowingRegistration) {
                    RegistrationView()
                        .environmentObject(authViewModel)
                }
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Login Failed"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
