//
//  DisplayNameView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/13/23.
//

import SwiftUI

@MainActor
final class DisplayNameViewModel: ObservableObject {
    @Published var displayName = ""

    func updateDisplayName() {
        Task {
            try await UserManager.shared.updateDisplayNameForUser(displayName: displayName)
        }
    }
}

struct DisplayNameView: View {
    @StateObject private var vm = DisplayNameViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()

            VStack {
                Text("Please enter a display name")
                    .font(.headline)
                    .foregroundColor(Color.theme.text)

                TextField("Display Name", text: $vm.displayName)
                    .padding()
                    .background(Color.theme.secondary)
                    .cornerRadius(10)
                    .padding()

                Button("Submit") {
                    vm.updateDisplayName()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct DisplayNameView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayNameView()
    }
}
