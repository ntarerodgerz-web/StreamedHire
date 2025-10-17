import SwiftUI
import UIKit

enum UserRole: String, CaseIterable, Identifiable {
    case candidate = "Candidate"
    case client    = "Client"
    var id: String { rawValue }
}

struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var firstName = ""
    @State private var lastName  = ""
    @State private var email     = ""
    @State private var password  = ""
    @State private var isSecure  = true
    @State private var role: UserRole? = nil

    // Navigate somewhere after successful sign-up (e.g., Profile)
    @State private var showProfile = false

    private var formFilled: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        role != nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Logo (use an asset named "signup_logo" if you have it; falls back to "signin_logo" or a black square)
                if let ui = UIImage(named: "StreamedHireLogo") ?? UIImage(named: "StreamedHireLogo") {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.top, 24)
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black)
                        .frame(width: 120, height: 120)
                        .padding(.top, 24)
                }

                // Title
                Text("Create Account")
                    .font(.title).bold()

                // First & Last name
                TextField("First Name", text: $firstName)
                    .textFieldBox()

                TextField("Last Name", text: $lastName)
                    .textFieldBox()

                // Email
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .textFieldBox()

                // Password w/ eye toggle
                HStack {
                    Group {
                        if isSecure {
                            SecureField("Password", text: $password)
                        } else {
                            TextField("Password", text: $password)
                        }
                    }
                    Button(action: { isSecure.toggle() }) {
                        Image(systemName: isSecure ? "eye" : "eye.slash")
                            .foregroundColor(.secondary)
                    }
                }
                .textFieldBox()

                // Account type (radio)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Account Type")
                        .font(.subheadline).fontWeight(.semibold)

                    HStack(spacing: 16) {
                        RadioChip(label: "Candidate", isSelected: role == .candidate) {
                            role = .candidate
                        }
                        RadioChip(label: "Client", isSelected: role == .client) {
                            role = .client
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Sign Up (black filled)
                Button {
                    guard formFilled else { return }
                    
                    // Save selected user role locally
                    if let role = role {
                        UserDefaults.standard.set(role.rawValue, forKey: "userRole")
                    }
                    
                    // Later, you can replace this with Firebase user creation
                    showProfile = true
                } label: {

                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(!formFilled)
                .opacity(formFilled ? 1 : 0.5)

                // Already have an account?
                Text("Already have an account?")
                    .font(.footnote)
                    .foregroundColor(.secondary)

                // Outlined Sign In
                NavigationLink(destination: SignInView()) {
                    Text("Sign In").fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
                .tint(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Label("Back", systemImage: "chevron.backward")
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        // Modern navigation to Profile after successful Sign Up
        .navigationDestination(isPresented: $showProfile) {
            ProfileView()
        }
    }
}

// MARK: - Small UI helpers

private struct RadioChip: View {
    let label: String
    var isSelected: Bool
    var tap: () -> Void

    var body: some View {
        Button(action: tap) {
            HStack(spacing: 8) {
                Image(systemName: isSelected ? "smallcircle.filled.circle" : "circle")
                Text(label)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.black.opacity(0.08) : Color(.systemGray6))
            )
        }
        .foregroundColor(.primary)
    }
}

private extension View {
    /// Matches the rounded, outlined text field style in your screenshots
    func textFieldBox() -> some View {
        self
            .padding(14)
            .background(Color(.systemBackground))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4)))
    }
}
#Preview {
    LandingView()
}
