//
//  AddFriendsView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/27/23.
//

import SwiftUI

struct AddFriendsView: View {
    @EnvironmentObject var socialVM: SocialViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel
    
    var body: some View {
        ScrollView {
            ForEach(socialVM.allUsers.sorted(by: { $0.displayName ?? "" < $1.displayName ?? "" }), id: \.userId) { user in
                if let currentUser = settingsVM.authUser, currentUser.uid != user.userId {
                    HStack {
                        VStack {
                            Text(user.displayName ?? "No Display Name")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        Button("Add Friend") {
                            socialVM.sendFriendRequest(userId: user.userId)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Cancel") {
                            socialVM.cancelFriendRequest(userId: user.userId)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
            }
        }
    }
}

struct AddFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendsView()
            .environmentObject(dev.socialVM)
            .environmentObject(dev.settingsVM)
    }
}
