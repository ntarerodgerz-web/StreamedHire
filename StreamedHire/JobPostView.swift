import SwiftUI
import UIKit

// Use fileprivate to avoid name clashes in other files
fileprivate enum JobType: String, CaseIterable, Identifiable {
    case fullTime = "Full-time"
    case partTime = "Part-time"
    case contract = "Contract"
    case internship = "Internship"
    case temporary = "Temporary"
    var id: String { rawValue }
}

fileprivate enum ShiftType: String, CaseIterable, Identifiable {
    case first = "1st"
    case second = "2nd"
    case third = "3rd"
    var id: String { rawValue }
}

struct JobPostView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: Company
    @State private var companyName = ""
    @State private var address      = ""
    @State private var city         = ""
    @State private var stateRegion  = ""
    @State private var zipCode      = ""
    @State private var supervisor   = ""   // Company Contact (supervisor)

    // MARK: Job basics
    @State private var jobTitle     = ""
    @State private var jobType: JobType = .fullTime

    // MARK: Job Description (detailed blocks)
    @State private var summary              = ""
    @State private var responsibilitiesText = "" // one per line
    @State private var skillsText           = "" // one per line
    @State private var requiredEducation    = ""
    @State private var requiredCertsText    = "" // one per line

    // MARK: Shift / Hours
    @State private var shift: ShiftType = .first
    @State private var startTime: Date = DateComponents(calendar: .current, hour: 9,  minute: 0).date ?? Date()
    @State private var endTime:   Date = DateComponents(calendar: .current, hour: 17, minute: 0).date ?? Date()

    // MARK: Dress code (PPE) & Budget
    @State private var dressCodePPE = ""  // e.g. "Hard hat, Safety boots, Hi-vis vest"
    @State private var budget       = ""  // e.g. "$70k–$100k USD" or hourly

    // MARK: Submit
    @State private var posting = false
    @State private var showPosted = false

    // Basic validation — adjust as you like
    private var formValid: Bool {
        !companyName.trim.isEmpty &&
        !address.trim.isEmpty &&
        !city.trim.isEmpty &&
        !stateRegion.trim.isEmpty &&
        !zipCode.trim.isEmpty &&
        !jobTitle.trim.isEmpty &&
        !summary.trim.isEmpty
    }

    var body: some View {
        Form {
            // 1) Company Name
            Section("Company Name") {
                TextField("Company *", text: $companyName)
            }

            // 2) Company Address (Address, City, State, Zip Code)
            Section("Company Address") {
                TextField("Address *", text: $address)
                HStack {
                    TextField("City *", text: $city)
                    TextField("State *", text: $stateRegion)
                    TextField("Zip Code *", text: $zipCode)
                        .keyboardType(.numbersAndPunctuation)
                        .frame(minWidth: 90)
                }
            }

            // 3) Company Contact (supervisor)
            Section("Company Contact (Supervisor)") {
                TextField("Supervisor Name", text: $supervisor)
            }

            // 4) Job Title
            Section("Job Title") {
                TextField("Job Title *", text: $jobTitle)
            }

            // 5) Job Type
            Section("Job Type") {
                Picker("Type *", selection: $jobType) {
                    ForEach(JobType.allCases) { Text($0.rawValue).tag($0) }
                }
            }

            // 6) Job Description (Summary, Responsibilities, Skills, Required Education, Required Certifications)
            Section("Job Description") {
                TextField("Summary *", text: $summary)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Responsibilities")
                        .font(.subheadline).fontWeight(.semibold)
                    TextEditor(text: $responsibilitiesText)
                        .frame(minHeight: 100)
                    if !responsibilitiesLines.isEmpty {
                        BulletedPreview(lines: responsibilitiesLines)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Skills")
                        .font(.subheadline).fontWeight(.semibold)
                    TextEditor(text: $skillsText)
                        .frame(minHeight: 100)
                    if !skillsLines.isEmpty {
                        BulletedPreview(lines: skillsLines)
                    }
                }

                TextField("Required Education", text: $requiredEducation)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Required Certifications")
                        .font(.subheadline).fontWeight(.semibold)
                    TextEditor(text: $requiredCertsText)
                        .frame(minHeight: 80)
                    if !certsLines.isEmpty {
                        BulletedPreview(lines: certsLines)
                    }
                }
            }

            // 7) Shift (1st, 2nd, 3rd)
            Section("Shift") {
                Picker("Shift", selection: $shift) {
                    ForEach(ShiftType.allCases) { Text($0.rawValue).tag($0) }
                }
            }

            // 8) Hours (Start time, End time)
            Section("Hours") {
                DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                DatePicker("End Time",   selection: $endTime,   displayedComponents: .hourAndMinute)
                if let durationText = workHoursDurationText {
                    Text(durationText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            // 9) Required Dress Code (PPE)
            Section("Required Dress Code (PPE)") {
                TextEditor(text: $dressCodePPE)
                    .frame(minHeight: 80)
                if !dressCodeLines.isEmpty {
                    BulletedPreview(lines: dressCodeLines)
                }
            }

            // 10) Budget
            Section("Budget") {
                TextField("e.g. $70k–$100k USD or $30/hour", text: $budget)
                    .keyboardType(.numbersAndPunctuation)
            }
        }
        .navigationTitle("Post a Job")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Label("Back", systemImage: "chevron.backward")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    submit()
                } label: {
                    if posting { ProgressView() } else { Text("Post") }
                }
                .disabled(!formValid || posting)
            }
        }
        .alert("Job posted!", isPresented: $showPosted) {
            Button("OK") { dismiss() }
        } message: {
            Text("“\(jobTitle)” at \(companyName) has been posted.")
        }
    }

    // MARK: Derived helpers

    private var responsibilitiesLines: [String] {
        responsibilitiesText.lines
    }
    private var skillsLines: [String] {
        skillsText.lines
    }
    private var certsLines: [String] {
        requiredCertsText.lines
    }
    private var dressCodeLines: [String] {
        dressCodePPE.lines
    }

    private var workHoursDurationText: String? {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: startTime, to: endTime)
        guard let h = comps.hour, let m = comps.minute else { return nil }
        let minutes = (h * 60) + m
        guard minutes > 0 else { return nil }
        let hh = minutes / 60
        let mm = minutes % 60
        return "Total: \(hh)h \(mm)m"
    }

    // MARK: Submit (stub)
    private func submit() {
        guard formValid else { return }
        posting = true

        // Build a payload you can later send to a backend
        let payload: [String: Any] = [
            "companyName": companyName.trim,
            "address": [
                "street": address.trim,
                "city": city.trim,
                "state": stateRegion.trim,
                "zip": zipCode.trim
            ],
            "supervisor": supervisor.trim,
            "jobTitle": jobTitle.trim,
            "jobType": jobType.rawValue,
            "description": [
                "summary": summary.trim,
                "responsibilities": responsibilitiesLines,
                "skills": skillsLines,
                "requiredEducation": requiredEducation.trim,
                "requiredCertifications": certsLines
            ],
            "shift": shift.rawValue,
            "hours": [
                "start": startTime.isoTime,
                "end": endTime.isoTime
            ],
            "dressCodePPE": dressCodeLines,
            "budget": budget.trim
        ]

        // Simulate a network post
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            // print(payload) // you can log this if you like
            posting = false
            showPosted = true
        }
    }
}

// MARK: - Small UI helpers

fileprivate struct BulletedPreview: View {
    let lines: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(lines, id: \.self) { Text("• \($0)") }
        }
        .foregroundStyle(.secondary)
        .padding(.top, 2)
    }
}

fileprivate extension String {
    var trim: String { trimmingCharacters(in: .whitespacesAndNewlines) }
    var lines: [String] {
        split(separator: "\n")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}

fileprivate extension Date {
    /// HH:mm in 24h for payload/logs
    var isoTime: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "HH:mm"
        return f.string(from: self)
    }
}
#Preview {
    LandingView()
}
