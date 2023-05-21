//
//  AddFriendsView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/27/23.
//

import NukeUI
import SwiftUI

struct AddFriendsView: View {
    @EnvironmentObject var socialVM: SocialViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel
    @EnvironmentObject var homeVM: HomeViewModel

    @Environment(\.dismiss) private var dismiss

    @State var filterText: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()

                VStack {
                    AddFriendsFilterView(filterText: $filterText)
                        .padding(.bottom)

                    ScrollView(showsIndicators: false) {
                        VStack {
                            ForEach(users, id: \.userId) { user in
                                if let currentUser = settingsVM.authUser, currentUser.uid != user.userId {
                                    HStack {
                                        LazyImage(url: URL(string: user.photoUrl ?? "")) { state in
                                            if let image = state.image {
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                            } else {
                                                Image(systemName: "person.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .padding()
                                                    .background(Color.theme.secondary)
                                            }
                                        }
                                        .clipShape(Circle())
                                        .frame(width: 50, height: 50)
                                        .padding(.trailing)

                                        VStack(alignment: .leading) {
                                            Text(user.displayName ?? "No Display Name")
                                                .font(.title3)
                                                .fontWeight(.semibold)

                                            Text(user.email ?? "No email")
                                                .font(.caption)
                                        }
                                        Spacer()

                                        Button(doesUserHavingPendingRequestFromCurrentUser(user: user) ? "Cancel" : "Add") {
                                            if doesUserHavingPendingRequestFromCurrentUser(user: user) {
                                                socialVM.cancelFriendRequest(userId: user.userId)
                                            } else {
                                                socialVM.sendFriendRequest(userId: user.userId)
                                            }

                                            socialVM.getUsersWithFriendRequestFor(userId: currentUser.uid)
                                        }
                                        .foregroundColor(
                                            !doesUserHavingPendingRequestFromCurrentUser(user: user)
                                                ? Color.theme.red
                                                : Color.theme.genreText)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .frame(width: 80, height: 30)
                                            .background(
                                                !doesUserHavingPendingRequestFromCurrentUser(user: user)
                                                    ? Color.theme.secondary
                                                    : Color.theme.red)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .fixedSize(horizontal: true, vertical: false)
                                    }
                                    .padding(.vertical)
                                }
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(Color.theme.red)
                            .fontWeight(.semibold)
                    }
                }
                .onAppear {
                    if let currentUser = settingsVM.authUser {
                        socialVM.getUsersWithFriendRequestFor(userId: currentUser.uid)
                    }
                }
                .padding()
            }
            .navigationTitle("Find Friends")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    var users: [DBUser] {
        let firstFilter = filterText.isEmpty
            ? socialVM.allUsers
            : socialVM.allUsers.filter { $0.displayName?.lowercased().contains(filterText.lowercased()) ?? false }

        return firstFilter
            .filter { !(socialVM.currentUser?.friends?.contains($0.userId) ?? false) }
    }

    /// Returns a bool on whether or not the passed in user has a pending request from the currnet user
    func doesUserHavingPendingRequestFromCurrentUser(user: DBUser) -> Bool {
        let usersWithFriendRequest = socialVM.usersWithFriendRequest
        for otherUser in usersWithFriendRequest {
            if otherUser.userId == user.userId {
                return true
            }
        }
        return false
    }
}

struct AddFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddFriendsView()
                .environmentObject(dev.socialVM)
                .environmentObject(dev.settingsVM)
                .environmentObject(dev.homeVM)
        }
    }
}

struct AddFriendsFilterView: View {
    @FocusState private var isFocused: Bool
    @Binding var filterText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(!isFocused ? Color.theme.red : Color.theme.text)
                .imageScale(.medium)

            TextField("Search...", text: $filterText)
                .foregroundColor(Color.theme.text)
                .font(.system(size: 16, design: .default))
                .submitLabel(.search)
                .focused($isFocused)
                .overlay(alignment: .trailing) {
                    if isFocused, !filterText.isEmpty {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                            .padding()
                            .offset(x: 15)
                            .foregroundColor(Color.theme.text)
                            .opacity(!isFocused ? 0.0 : 1.0)
                            .onTapGesture {
                                filterText = ""
                            }
                    }
                }
        }
        .font(.headline)
        .padding()
        .frame(height: 40)
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .background(Color.theme.secondary)
        .cornerRadius(20)
    }
}
