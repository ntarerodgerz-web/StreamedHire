import SwiftUI
import UIKit

// Entry
struct ContentView: View {
    var body: some View { LandingView() }
}

// Bottom sheets we can open
private enum BottomModal: Identifiable {
    case profile, jobs, apply, login, create, postJob
    var id: Int { hashValue }
}

// Menu items
private enum MenuSelection { case home, create, login, jobs, applications, profile, postJob }

// MARK: - Landing Page
struct LandingView: View {
    @State private var searchText = ""
    @State private var modal: BottomModal?
    @State private var showMenu = false
    @State private var userRole: UserRole? = nil


    // Rotating banners + featured selection
    @State private var landingBanners = ["landing1", "landing2", "landing3"] // replace with your asset names
    @State private var selectedFeatured: FeaturedJob? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {

                        // Title
                        HStack {
                            Text("Find your dream job")
                                .font(.system(size: 34, weight: .bold))
                                .padding(.top, 8)
                            Spacer()
                        }
                        .padding(.horizontal, 20)

                        // Search
                        HStack { SearchBar(query: $searchText) }
                            .padding(.horizontal, 20)

                        // ✅ Auto-rotating landing banner (full-width, larger height)
                        AutoPagingTabView(items: landingBanners, interval: 5) { name in
                            Group {
                                if UIImage(named: name) != nil {
                                    Image(name).resizable().scaledToFill()
                                } else {
                                    LinearGradient(colors: [.gray.opacity(0.6), .gray.opacity(0.2)],
                                                   startPoint: .top, endPoint: .bottom)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                        }
                        .frame(height: 260)                 // ⬅️ increase/decrease as you like
                        .padding(.horizontal, 0)            // edge-to-edge

                        // ✅ Featured jobs (auto-slide + tap to open details) + "Posted" info
                        if !FeaturedJob.sample.isEmpty {
                            AutoPagingTabView(items: FeaturedJob.sample, interval: 4) { job in
                                Button {
                                    selectedFeatured = job          // open detail sheet
                                } label: {
                                    FeaturedJobCard(job: job)       // single-card view
                                        .padding(.horizontal, 20)
                                }
                                .buttonStyle(.plain)
                            }
                            .frame(height: 230)
                            .padding(.bottom, 6)
                        }
                    }
                    .padding(.bottom, 16)
                }

                // Bottom buttons
                HStack {
                    BottomBarButton(icon: "person.crop.circle", label: "Profile") {
                        modal = .profile
                    }
                    Spacer()
                    BottomBarButton(icon: "briefcase.fill", label: "Jobs") {
                        modal = .jobs
                    }
                    Spacer()
                    BottomBarButton(icon: "paperplane.fill", label: "Apply") {
                        modal = .apply
                    }
                    
                }
                .padding(.horizontal, 26)
                .padding(.top, 10)
                .padding(.bottom, 12)
                .background(.ultraThinMaterial)
            }
            .onAppear {
                if let savedRole = UserDefaults.standard.string(forKey: "userRole") {
                    userRole = UserRole(rawValue: savedRole)
                    print("Loaded user role:", savedRole)
                } else {
                    print("No role saved yet")
                }
            }

            .navigationTitle("Streamed Hire")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // iOS 15-safe placements
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showMenu = true } label: {
                        Image(systemName: "line.3.horizontal").font(.title3)
                    }
                    .accessibilityLabel("Menu")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { modal = .login } label: {
                        Text("Log in / Create").font(.subheadline.weight(.semibold))
                    }
                }
            }
            // Menu sheet
            .sheet(isPresented: $showMenu) {
                MenuSheet (userRole: userRole){ selection in
                    showMenu = false
                    switch selection {
                    case .home: break
                    case .create: modal = .create
                    case .login: modal = .login
                    case .jobs: modal = .jobs
                    case .applications: modal = .apply
                    case .profile: modal = .profile
                    case .postJob: modal = .postJob
                    }
                }
            }

            // Pages opened from bottom buttons or menu
            .sheet(item: $modal) { which in
                switch which {
                case .profile:     NavigationStack { ProfileView() }
                case .jobs:        NavigationStack { JobsView() }
                case .apply:       NavigationStack { ApplicationsView() }
                case .login:       NavigationStack {
                    SignInView(onSignedIn: {
                        modal = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) { showMenu = true }
                    })
                }
                    
                case .create:      NavigationStack { CreateAccountView() }
                case .postJob:     NavigationStack { JobPostView() }
                }
            }
            // Featured job detail sheet
            .sheet(item: $selectedFeatured) { job in
                NavigationStack {
                    JobDetailView(
                        jobTitle: job.title,
                        company: job.company,
                        location: job.location,
                        employmentType: "full-time",
                        salaryRange: "$70,000–100,000 USD",
                        rating: 4.5,
                        descriptionText: "Role description goes here…",
                        requirements: [
                            "3+ years relevant experience",
                            "Strong communication skills",
                            "Cross-functional teamwork"
                        ],
                        companyAbout: job.company,
                        heroImageName: "job_hero" // optional asset; gradient fallback if missing
                    )
                }
            }
        }
    }
}

// MARK: - Menu Sheet
// MARK: - Menu Sheet
private struct MenuSheet: View {
    let userRole: UserRole?
    let onSelect: (MenuSelection) -> Void
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: { onSelect(.home) },
                           label: { Label("Home", systemImage: "house.fill") })
                    Button(action: { onSelect(.create) },
                           label: { Label("Create an account", systemImage: "person.badge.plus") })
                    Button(action: { onSelect(.login) },
                           label: { Label("Login", systemImage: "person.crop.circle.badge.checkmark") })
                }
                Section {
                    Button(action: { onSelect(.jobs) },
                           label: { Label("Jobs", systemImage: "briefcase.fill") })
                    Button(action: { onSelect(.applications) },
                           label: { Label("Applications", systemImage: "paperplane.fill") })
                    Button(action: { onSelect(.profile) },
                           label: { Label("Profile", systemImage: "person.crop.circle") })
                    Button(action: { onSelect(.postJob) },
                           label: { Label("Post a Job", systemImage: "briefcase") })
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])   // ✅ ensures all buttons visible
    }
}


// MARK: - Pieces

private struct SearchBar: View {
    @Binding var query: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
            TextField("Search for jobs", text: $query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6)))
    }
}

// Single featured card used inside the pager
private struct FeaturedJobCard: View {
    let job: FeaturedJob
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title + company/location
            VStack(alignment: .leading, spacing: 6) {
                Text(job.title).font(.system(size: 22, weight: .semibold))
                HStack(spacing: 8) {
                    Text(job.company)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Text("•").foregroundColor(.secondary)
                    Image(systemName: "mappin.and.ellipse")
                        .imageScale(.small)
                        .foregroundColor(.secondary)
                    Text(job.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .accessibilityElement(children: .combine)
            }

            // ✅ Posted date indicator
            HStack {
                Label("Posted \(job.postedOn.formatted(date: .abbreviated, time: .omitted))",
                      systemImage: "calendar")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
}

private struct BottomBarButton: View {
    let icon: String
    let label: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.title3)
                Text(label).font(.footnote)
            }
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color.accentColor)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.accentColor.opacity(0.12)))
        }
    }
}

// MARK: - Sample data (now includes postedOn)
private struct FeaturedJob: Identifiable {
    let id = UUID()
    let title: String
    let company: String
    let location: String
    let postedOn: Date

    static let sample: [FeaturedJob] = [
        .init(title: "Software Engineer", company: "TechCorp",     location: "Kampala, UG",  postedOn: Date().addingTimeInterval(-86400 * 1)),
        .init(title: "Product Manager",   company: "Innovate LLC", location: "Kigali, RW",   postedOn: Date().addingTimeInterval(-86400 * 3)),
        .init(title: "UX Designer",       company: "Creative Labs",location: "Bujumbura, BI",postedOn: Date().addingTimeInterval(-86400 * 6))
    ]
}

#Preview {
    LandingView()
}
