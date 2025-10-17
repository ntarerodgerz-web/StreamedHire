//
//  ProfileView.swift
//  lifex2
//
//  Created by NTARE on 10/09/2025.
//


import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Form {
            Section {
                Label("Ntare Rodgers", systemImage: "person.crop.circle")
                Text("IT Director, GBTF Africa").foregroundStyle(.secondary)
            }
            Section {
                Button("Edit Profile") { }
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Text("Sign out")
                }

            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                Button(action: { dismiss() }) { Label("Back", systemImage: "chevron.backward") }
//            }
//        }
    }
}

#Preview {
    LandingView()
}
