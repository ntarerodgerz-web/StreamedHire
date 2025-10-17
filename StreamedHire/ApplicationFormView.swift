import SwiftUI
import UniformTypeIdentifiers

struct ApplicationFormView: View {
    @Environment(\.dismiss) private var dismiss

    // Passed in from JobDetailView
    let jobTitle: String
    let company: String
    let location: String

    // Fields (your order)
    @State private var firstName = ""
    @State private var lastName  = ""
    @State private var address1  = ""
    @State private var address2  = ""   // optional
    @State private var city      = ""
    @State private var state     = ""
    @State private var zipCode   = ""
    @State private var mobile    = ""
    @State private var email     = ""
    @State private var message   = ""

    // CV upload
    @State private var resumeURL: URL?
    @State private var showingFilePicker = false

    // Submit state
    @State private var sending = false
    @State private var showSentAlert = false

    // Validation
    private var formValid: Bool {
        !firstName.trim.isEmpty &&
        !lastName.trim.isEmpty &&
        !address1.trim.isEmpty &&
        !city.trim.isEmpty &&
        !state.trim.isEmpty &&
        !zipCode.trim.isEmpty &&
        !mobile.trim.isEmpty &&
        email.contains("@") &&
        !message.trim.isEmpty
    }

    var body: some View {
        Form {
            // Context (optional)
            Section("Position") {
                Text(jobTitle).font(.headline)
                Text("\(company) — \(location)").foregroundStyle(.secondary)
            }

            // Styled fields (grey bordered boxes)
            Section {
                VStack(spacing: 12) {
                    TextField("First name", text: $firstName)
                        .textFieldBox()

                    TextField("Last name", text: $lastName)
                        .textFieldBox()

                    TextField("Address 1", text: $address1)
                        .textFieldBox()

                    TextField("Address 2 (Optional)", text: $address2)
                        .textFieldBox()

                    TextField("City", text: $city)
                        .textFieldBox()

                    TextField("State", text: $state)
                        .textFieldBox()

                    TextField("Zip Code", text: $zipCode)
                        .keyboardType(.numbersAndPunctuation)
                        .textFieldBox()

                    TextField("Mobile Number", text: $mobile)
                        .keyboardType(.phonePad)
                        .textFieldBox()

                    TextField("Email address", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .textFieldBox()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Message (Your cover letter / your message to the employer)")
                            .font(.subheadline).fontWeight(.semibold)
                        TextEditor(text: $message)
                            .textEditorBox(minHeight: 160)
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            // Upload CV (boxed area)
            Section("Upload CV") {
                VStack(spacing: 10) {
                    if let url = resumeURL {
                        HStack(spacing: 10) {
                            Image(systemName: "doc.text")
                            Text(url.lastPathComponent).lineLimit(1)
                            Spacer()
                            Button("Remove", role: .destructive) { resumeURL = nil }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fieldBoxLike()
                    }

                    Button {
                        showingFilePicker = true
                    } label: {
                        Label(resumeURL == nil ? "Choose File" : "Replace File", systemImage: "paperclip")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(.black)
                    .fieldBoxLike() // gives it the same grey outline feel
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            // Send button (prominent)
            Section {
                Button {
                    sendApplication()
                } label: {
                    HStack {
                        if sending { ProgressView() }
                        Text("Send Application").fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(.black)
                .disabled(!formValid || sending)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .navigationTitle("Apply (ApplicationFormView)")
        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            // iOS 15-safe placement
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: { dismiss() }) {
//                    Label("Back", systemImage: "chevron.backward")
//                }
//            }
//        }
        .fileImporter(isPresented: $showingFilePicker, allowedContentTypes: allowedCVTypes) { result in
            switch result {
            case .success(let url): resumeURL = url
            case .failure: resumeURL = nil
            }
        }
        .alert("Application sent!", isPresented: $showSentAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("We’ve recorded your application for \(jobTitle) at \(company).")
        }
    }

    private var allowedCVTypes: [UTType] {
        var types: [UTType] = [.pdf]
        if let docx = UTType(filenameExtension: "docx") { types.append(docx) }
        if let doc  = UTType(filenameExtension: "doc")  { types.append(doc) }
        return types
    }

    private func sendApplication() {
        guard formValid else { return }
        sending = true

        // Build payload (replace with your API call later)
        let payload: [String: Any] = [
            "job": ["title": jobTitle, "company": company, "location": location],
            "applicant": [
                "firstName": firstName.trim, "lastName": lastName.trim,
                "address1": address1.trim,   "address2": address2.trim,
                "city": city.trim,           "state": state.trim,
                "zipCode": zipCode.trim,     "mobile": mobile.trim,
                "email": email.trim,         "message": message.trim
            ],
            "cvFile": resumeURL?.lastPathComponent ?? "none"
        ]
        // print(payload)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            sending = false
            showSentAlert = true
        }
    }
}

// MARK: - Styling helpers

private extension View {
    /// Single-line field box (grey border, rounded)
    func textFieldBox() -> some View {
        self
            .padding(14)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }

    /// Multiline editor box (grey border, rounded)
    func textEditorBox(minHeight: CGFloat) -> some View {
        self
            .frame(minHeight: minHeight, alignment: .topLeading)
            .padding(10)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }

    /// Generic container to mimic the same box look (for CV row/buttons)
    func fieldBoxLike() -> some View {
        self
            .padding(12)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

private extension String {
    var trim: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
#Preview {
    LandingView()
}
