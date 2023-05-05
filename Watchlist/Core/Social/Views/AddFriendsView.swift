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
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            VStack {
                Text("Add Friends")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(Color.theme.text)
                
                AddFriendsFilterView(filterText: $filterText)
                    .padding(.bottom)
                
                ScrollView {
                    HStack {
                        Text("Quick Add")
                            .font(.title3)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    
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
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .padding(.trailing)
                                    
                                    VStack(alignment: .leading) {
                                        Text(user.displayName ?? "No Display Name")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                        
                                        Text(user.email ?? "No email")
                                            .font(.caption)
                                    }
                                    Spacer()
                                    
                                    Button(doesUserContainCurrentUser(user: user) ? "Cancel" : "Add") {
                                        if doesUserContainCurrentUser(user: user) {
                                            socialVM.cancelFriendRequest(userId: user.userId)
                                        } else {
                                            socialVM.sendFriendRequest(userId: user.userId)
                                        }
                                        
                                        socialVM.getUsersWithFriendRequestFor(userId: currentUser.uid)
                                    }
                                    .foregroundColor(!doesUserContainCurrentUser(user: user) ? Color.theme.red : Color.theme.genreText)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .frame(width: 80, height: 30)
                                    .background(!doesUserContainCurrentUser(user: user) ? Color.theme.secondary : Color.theme.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .fixedSize(horizontal: true, vertical: false)
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                    .padding()
                    .background(Color.theme.secondary.opacity(0.5))
                    .cornerRadius(10)
                }
            }
            .overlay(alignment: .topLeading) {
                Image(systemName: "chevron.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.theme.text)
                    .fontWeight(.semibold)
                    .buttonStyle(.plain)
                    .padding(.all, 5)
                    .accessibility(label: Text("Close"))
                    .accessibility(hint: Text("Tap to close the screen"))
                    .accessibility(addTraits: .isButton)
                    .accessibility(removeTraits: .isImage)
                    .onTapGesture {
                        homeVM.hapticFeedback.impactOccurred()
                        dismiss()
                    }
            }
            .onAppear {
                if let currentUser = settingsVM.authUser {
                    socialVM.getUsersWithFriendRequestFor(userId: currentUser.uid)
                }
            }
            .padding()
        }
    }
    
    var users: [DBUser] {
        filterText.isEmpty ?
            socialVM.allUsers.sorted(by: { $0.displayName ?? "" < $1.displayName ?? "" })
            :
            socialVM.allUsers.sorted(by: { $0.displayName ?? "" < $1.displayName ?? "" }).filter { $0.displayName?.lowercased().contains(filterText.lowercased()) ?? false }
    }
    
    func doesUserContainCurrentUser(user: DBUser) -> Bool {
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
        AddFriendsView()
            .environmentObject(dev.socialVM)
            .environmentObject(dev.settingsVM)
            .environmentObject(dev.homeVM)
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
        }
        .font(.headline)
        .padding()
        .frame(height: 40)
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .background(Color.theme.secondary)
        .cornerRadius(20)
    }
}
