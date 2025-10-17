import SwiftUI

struct ApplicationDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let application: ApplicationRecord

    var body: some View {
        Form {
            Section("Position") {
                Text(application.jobTitle).font(.headline)
                Text("\(application.company) — \(application.location)")
                    .foregroundStyle(.secondary)
            }

            Section("Status") {
                HStack {
                    Text("Current Status")
                    Spacer()
                    StatusPill(status: application.status)
                }
                HStack {
                    Text("Submitted On")
                    Spacer()
                    Text(application.submittedOn.formatted(date: .abbreviated, time: .omitted))
                        .foregroundStyle(.secondary)
                }
            }

            Section("Applicant") {
                HStack {
                    Text("Name")
                    Spacer()
                    Text("\(application.firstName) \(application.lastName)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Mobile")
                    Spacer()
                    Text(application.mobile).foregroundStyle(.secondary)
                }
                HStack {
                    Text("Email")
                    Spacer()
                    Text(application.email).foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
            }

            Section("Address") {
                Text(application.address1)
                if let a2 = application.address2, !a2.isEmpty {
                    Text(a2)
                }
                Text("\(application.city), \(application.state) \(application.zipCode)")
                    .foregroundStyle(.secondary)
            }

            Section("Message") {
                Text(application.message)
            }

            Section("CV") {
                if let name = application.resumeFilename, !name.isEmpty {
                    Label(name, systemImage: "doc.text")
                } else {
                    Text("No file attached").foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Submission Details (ApplicationDetailsView)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // iOS 15-safe placement
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Label("Back", systemImage: "chevron.backward")
                }
            }
        }
    }
}
#Preview {
    LandingView()
}
