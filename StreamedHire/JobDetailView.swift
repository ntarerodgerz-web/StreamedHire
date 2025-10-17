import SwiftUI
import UIKit

struct JobDetailView: View {
    @Environment(\.dismiss) private var dismiss

    // Job fields
    let jobTitle: String
    let company: String
    let location: String
    let employmentType: String
    let salaryRange: String
    let rating: Double
    let descriptionText: String
    let requirements: [String]
    let companyAbout: String
    let heroImageName: String?

    // 👉 Navigation to the application form
    @State private var showApplicationForm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Hero + floating info card
                ZStack(alignment: .bottom) {
                    HeroImage(name: heroImageName)
                    InfoCard(
                        jobTitle: jobTitle,
                        location: location,
                        employmentType: employmentType,
                        salaryRange: salaryRange,
                        rating: rating
                    )
                    .padding(.horizontal, 16)
                    .offset(y: 24)
                }
                .padding(.bottom, 24)

                // Sections
                SectionBlock(title: "Job Description", text: descriptionText)
                RequirementsBlock(requirements: requirements)
                SectionBlock(title: "About Company", text: companyAbout)

                Spacer(minLength: 10)
            }
        }
        .navigationTitle(jobTitle)
        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                Button(action: { dismiss() }) { Image(systemName: "chevron.backward") }
//            }
//        }
        // Sticky bottom Apply button -> pushes form
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Divider()
                Button {
                    showApplicationForm = true
                } label: {
                    Text("Apply")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.black)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(.ultraThinMaterial)
        }
        // Modern navigation in a NavigationStack
        .navigationDestination(isPresented: $showApplicationForm) {
            ApplicationFormView(
                jobTitle: jobTitle,
                company: company,
                location: location
            )
        }
    }
}

// MARK: - Pieces

private struct HeroImage: View {
    let name: String?
    var body: some View {
        Group {
            if let name, UIImage(named: name) != nil {
                Image(name).resizable().scaledToFill()
            } else {
                LinearGradient(colors: [.gray.opacity(0.6), .gray.opacity(0.2)],
                               startPoint: .top, endPoint: .bottom)
            }
        }
        .frame(height: 220)
        .clipped()
    }
}

private struct InfoCard: View {
    let jobTitle: String
    let location: String
    let employmentType: String
    let salaryRange: String
    let rating: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(jobTitle).font(.headline.weight(.semibold))
                Text(location).font(.subheadline).foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                TagChip(text: employmentType, systemImage: "briefcase.fill").tintColor(.green)
                TagChip(text: salaryRange, systemImage: "banknote.fill").tintColor(.green)
                TagChip(text: String(format: "%.1f", rating), systemImage: "star.fill").tintColor(.yellow)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
        )
    }
}

private struct TagChip: View {
    let text: String
    var systemImage: String?
    private var color: Color

    // ✅ Public initializer so you can construct TagChip(...)
    init(text: String, systemImage: String? = nil, color: Color = .green) {
        self.text = text
        self.systemImage = systemImage
        self.color = color
    }

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage { Image(systemName: systemImage).imageScale(.small) }
            Text(text).font(.caption).fontWeight(.semibold)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
        .foregroundStyle(color)
    }

    // easy way to change color fluently
    func tintColor(_ color: Color) -> TagChip { var c = self; c.color = color; return c }
}

private struct SectionBlock: View {
    let title: String
    let text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Text(text).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
    }
}

private struct RequirementsBlock: View {
    let requirements: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Requirements").font(.headline)
            VStack(alignment: .leading, spacing: 6) {
                ForEach(requirements, id: \.self) { Text("• \($0)") }
            }
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
    }
}
#Preview {
    LandingView()
}
