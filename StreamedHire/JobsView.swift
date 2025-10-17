import SwiftUI

struct JobsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""

    private var filteredJobs: [JobRecord] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return JobRecord.sample }
        return JobRecord.sample.filter {
            $0.title.lowercased().contains(q) ||
            $0.company.lowercased().contains(q) ||
            $0.location.lowercased().contains(q)
        }
    }

    var body: some View {
        List {
            // Search field
            Section {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                    TextField("Search jobs", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
            }

            // Tappable rows
            Section {
                ForEach(filteredJobs) { job in
                    NavigationLink {
                        JobDetailView(
                            jobTitle: job.title,
                            company: job.company,
                            location: job.location,
                            employmentType: "full-time",
                            salaryRange: "$70,000–100,000 USD",
                            rating: 4.5,
                            descriptionText: "Work on building responsive and accessible UIs for millions of users.",
                            requirements: [
                                "3+ years experience with Swift/SwiftUI",
                                "Strong understanding of design systems and accessibility",
                                "Ability to ship features end-to-end"
                            ],
                            companyAbout: job.company,
                            heroImageName: job.heroImageName     // ← per-job banner
                        )
                    } label: {
                        JobsListRow(job: job)
                            .contentShape(Rectangle())
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Jobs (JobsView)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Label("Back", systemImage: "chevron.backward")
                }
            }
            
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: { dismiss() }) { Image(systemName: "chevron.backward") }
                        }
                    }
            
        }
    }


// MARK: - Local types to avoid clashes elsewhere

fileprivate struct JobsListRow: View {
    let job: JobRecord
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(job.title).font(.headline)
            Text(job.company).font(.subheadline).foregroundStyle(.secondary)
            HStack(spacing: 12) {
                Label(job.location, systemImage: "mappin.and.ellipse")
                    .font(.footnote).foregroundStyle(.secondary)
                Label("Posted \(job.postedOn)", systemImage: "calendar")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

fileprivate struct JobRecord: Identifiable {
    let id = UUID()
    let title: String
    let company: String
    let location: String
    let postedOn: String
    let heroImageName: String?   // ← NEW

    static let sample: [JobRecord] = [
        .init(title: "Software Engineer (iOS)", company: "TechCorp",      location: "Kampala, UG",      postedOn: "Aug 31, 2025", heroImageName: "job_banner_ios"),
        .init(title: "Backend Developer",       company: "CloudNine",     location: "Kigali, RW",       postedOn: "Aug 30, 2025", heroImageName: "job_banner_backend"),
        .init(title: "UI/UX Designer",          company: "Creative Labs", location: "Bujumbura, BI",    postedOn: "Aug 29, 2025", heroImageName: "job_banner_design"),
        .init(title: "Data Analyst",            company: "Insight AI",    location: "Nairobi, KE",      postedOn: "Aug 29, 2025", heroImageName: "job_banner_data"),
        .init(title: "Product Manager",         company: "Innovate LLC",  location: "Kampala, UG",      postedOn: "Aug 28, 2025", heroImageName: "job_banner_pm"),
        .init(title: "QA Engineer",             company: "QualityPro",    location: "Dar es Salaam, TZ",postedOn: "Aug 27, 2025", heroImageName: "job_banner_qa"),
        .init(title: "DevOps Engineer",         company: "ShipFast",      location: "Mbarara, UG",      postedOn: "Aug 27, 2025", heroImageName: "job_banner_devops"),
        .init(title: "Support Specialist",      company: "HelpDesk Co",   location: "Goma, DRC",        postedOn: "Aug 26, 2025", heroImageName: "job_banner_support"),
        .init(title: "Frontend Developer",      company: "PixelWorks",    location: "Bukavu, DRC",      postedOn: "Aug 25, 2025", heroImageName: "job_banner_frontend"),
        .init(title: "Solutions Architect",     company: "CloudBridge",   location: "Arusha, TZ",       postedOn: "Aug 24, 2025", heroImageName: "job_banner_arch")
    ]
}
#Preview {
    LandingView()
}
