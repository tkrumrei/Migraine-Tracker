import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showingChangePassword = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Personal Information")) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Name")
                                .font(.headline)
                            TextField("Enter your name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1) // optionaler Rahmen
                                )
                                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)

                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .font(.headline)
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1) // optionaler Rahmen
                                )
                                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 25)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                Section(header: Text("Security")) {
                    Button(action: {
                        showingChangePassword.toggle()
                    }) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.cyan)
                            Text("Change Password")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding() // Abstand innen
                        .background(Color(.systemGray6)) // grauer Kasten
                        .cornerRadius(10) // runde Ecken
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1) // optionaler Rahmen
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1) // leichter Schatten
                    }
                    .buttonStyle(PlainButtonStyle()) // damit es nicht wie ein blauer iOS-Button aussieht
                }
            }
            .navigationTitle("Edit Profile")
            .listStyle(.insetGrouped) // oder .plain
            .background(Color.white) // ← füge das hier hinzu
            .scrollContentBackground(.hidden)
            .onAppear {
                loadCurrentUserData()
            }
            .alert("Profile Update", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showingChangePassword) {
                ChangePasswordView()
                    .environmentObject(authViewModel)
            }
        }
    }
    
    private func loadCurrentUserData() {
        if let user = authViewModel.currentUser {
            name = user.name
            email = user.email
        }
    }
    
    private func saveProfile() {
        guard !name.isEmpty, !email.isEmpty else {
            alertMessage = "Please fill in all required fields."
            showAlert = true
            return
        }
        
        if !isValidEmail(email) {
            alertMessage = "Please enter a valid email address."
            showAlert = true
            return
        }
        
        let success = authViewModel.updateProfile(name: name, email: email)
        
        if success {
            alertMessage = "Profile updated successfully!"
        } else {
            alertMessage = "Failed to update profile. Please try again."
        }
        showAlert = true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

struct ChangePasswordView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Change Password")) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Current Password")
                                .font(.headline)
                            SecureField("Enter current password", text: $currentPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("New Password")
                                .font(.headline)
                            SecureField("Enter new password", text: $newPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Confirm Password")
                                .font(.headline)
                            SecureField("Confirm new password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 25)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                Section(footer: Text("Password must be at least 6 characters long.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Change Password")
            .listStyle(.insetGrouped)
            .background(Color.white)
            .scrollContentBackground(.hidden)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    changePassword()
                }
                .disabled(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
            )
            .alert("Password Change", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func changePassword() {
        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            alertMessage = "Please fill in all fields."
            showAlert = true
            return
        }

        guard newPassword.count >= 6 else {
            alertMessage = "Password must be at least 6 characters long."
            showAlert = true
            return
        }

        guard newPassword == confirmPassword else {
            alertMessage = "New passwords do not match."
            showAlert = true
            return
        }

        let success = authViewModel.changePassword(currentPassword: currentPassword, newPassword: newPassword)

        if success {
            alertMessage = "Password changed successfully!"
        } else {
            alertMessage = "Current password is incorrect."
        }
        showAlert = true
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
            .environmentObject(AuthViewModel())
    }
}
