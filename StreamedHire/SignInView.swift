import SwiftUI
import UIKit

struct SignInView: View {
    // 👉 Will be set by LandingView; when called we’ll dismiss & open the Menu
    var onSignedIn: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSecure: Bool = true
    @State private var isLoading: Bool = false

    private var formFilled: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Logo
                if UIImage(named: "StreamedHireLogo") != nil {
                    Image("StreamedHireLogo")
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

                Text("Streamed Hire").font(.title).bold()

                // Email
                HStack {
                    TextField("Enter your email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                .padding(14)
                .background(Color(.systemBackground))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4)))

                // Password + eye toggle
                HStack {
                    Group {
                        if isSecure {
                            SecureField("Enter your password", text: $password)
                        } else {
                            TextField("Enter your password", text: $password)
                        }
                    }
                    Button(action: { isSecure.toggle() }) {
                        Image(systemName: isSecure ? "eye" : "eye.slash")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(14)
                .background(Color(.systemBackground))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4)))

                // Sign In -> call onSignedIn()
                Button {
                    guard formFilled else { return }
                    isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isLoading = false
                        onSignedIn?()         // 👉 tell LandingView we’re signed in
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isLoading { ProgressView().tint(.white) }
                        Text("Sign In").fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(!formFilled)
                .opacity(formFilled ? 1 : 0.5)

                // “New here?” + Sign Up
                Text("New here?").font(.footnote).foregroundColor(.secondary)
                NavigationLink(destination: CreateAccountView()) {
                    Text("Sign Up").fontWeight(.semibold)
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
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                Button(action: { dismiss() }) { Label("Back", systemImage: "chevron.backward") }
//            }
//        }
       
        .background(Color(.systemGroupedBackground))
    }
}
#Preview {
    LandingView()
}
