import SwiftUI

struct ApplicationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var selected: ApplicationRecord? = nil   // ← tap target

    // Filterable data (replace with your store later)
    private var filtered: [ApplicationRecord] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return ApplicationRecord.sample }
        return ApplicationRecord.sample.filter {
            $0.jobTitle.lowercased().contains(q) ||
            $0.company.lowercased().contains(q) ||
            $0.city.lowercased().contains(q) ||
            $0.state.lowercased().contains(q)
        }
    }

    var body: some View {
        List {
            // Search
            Section {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                    TextField("Search applications", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
            }

            // Tappable rows → open sheet
            Section {
                ForEach(filtered) { app in
                    Button {
                        selected = app                       // ← open details
                    } label: {
                        ApplicationRow(app: app)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)                      // keep row look
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("ApplicationsView")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // iOS 15-safe placement
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Label("Back", systemImage: "chevron.backward")
                }
            }
        }
        // Sheet with details (works even without NavigationStack)
        .sheet(item: $selected) { app in
            NavigationStack {
                ApplicationDetailView(application: app)
            }
        }
    }
}

// MARK: - Row + Pill

struct ApplicationRow: View {
    let app: ApplicationRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(app.jobTitle)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                StatusPill(status: app.status)
            }

            Text(app.company)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            HStack(spacing: 12) {
                Label("\(app.city), \(app.state)", systemImage: "mappin.and.ellipse")
                Label(app.submittedOn.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

struct StatusPill: View {
    let status: ApplicationStatus
    var body: some View {
        Text(status.rawValue)
            .font(.caption).fontWeight(.semibold)
            .padding(.vertical, 4).padding(.horizontal, 8)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch status {
        case .submitted: return Color.blue.opacity(0.15)
        case .reviewing: return Color.orange.opacity(0.18)
        case .interview: return Color.purple.opacity(0.18)
        case .rejected:  return Color.red.opacity(0.18)
        case .accepted:  return Color.green.opacity(0.18)
        }
    }
    private var foregroundColor: Color {
        switch status {
        case .submitted: return .blue
        case .reviewing: return .orange
        case .interview: return .purple
        case .rejected:  return .red
        case .accepted:  return .green
        }
    }
}

// MARK: - Demo Model (keep only one copy project-wide)

enum ApplicationStatus: String {
    case submitted  = "Submitted"
    case reviewing  = "Reviewing"
    case interview  = "Interview"
    case rejected   = "Rejected"
    case accepted   = "Accepted"
}

struct ApplicationRecord: Identifiable, Equatable {
    let id = UUID()

    // Position
    let jobTitle: String
    let company: String
    let location: String

    // Applicant
    let firstName: String
    let lastName: String
    let address1: String
    let address2: String?
    let city: String
    let state: String
    let zipCode: String
    let mobile: String
    let email: String
    let message: String
    let resumeFilename: String?

    // Meta
    let submittedOn: Date
    let status: ApplicationStatus

    static let sample: [ApplicationRecord] = [
        .init(
            jobTitle: "iOS Engineer",
            company: "TechCorp",
            location: "Kampala, UG",
            firstName: "Jane", lastName: "Doe",
            address1: "123 Main St", address2: "Apt 5B",
            city: "Kampala", state: "Central", zipCode: "00100",
            mobile: "+256700000000",
            email: "jane@example.com",
            message: "Excited to contribute to your iOS team.",
            resumeFilename: "JaneDoe_CV.pdf",
            submittedOn: Date().addingTimeInterval(-86400 * 2),
            status: .reviewing
        ),
        .init(
            jobTitle: "Product Manager",
            company: "Innovate LLC",
            location: "Dar es Salaam, TZ",
            firstName: "Mike", lastName: "Kimani",
            address1: "7 Ocean Rd", address2: nil,
            city: "Dar es Salaam", state: "DSM", zipCode: "14111",
            mobile: "+255712345678",
            email: "mike@example.com",
            message: "Attached is my CV. Looking forward to an interview.",
            resumeFilename: "MikeK_PM.docx",
            submittedOn: Date().addingTimeInterval(-86400 * 6),
            status: .submitted
        )
    ]
}
#Preview {
    LandingView()
}
