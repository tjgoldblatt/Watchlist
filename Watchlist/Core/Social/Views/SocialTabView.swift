//
//  SocialTabView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/11/23.
//

import SwiftUI
import FirebaseFirestoreSwift

struct SocialTabView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    
    @StateObject var settingsVM = SettingsViewModel()
    
    @State private var showSignInView: Bool = false
    @StateObject var vm = SocialViewModel()
    
    @State var showSettingsView: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                VStack(alignment: .center) {
                    header
                    
                    if settingsVM.authUser?.isAnonymous == false {
                        if !vm.friendRequests.isEmpty {
                            Text("Friend Requests")
                                .font(.headline)
                            
                            ForEach(vm.friendRequests) { friendRequest in
                                HStack {
                                    Text(friendRequest.displayName ?? "None")
                                    
                                    Button("Accept") {
                                        vm.acceptFriendRequest(userId: friendRequest.userId)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    
                                    Button("Decline") {
                                        vm.declineFriendRequest(userId: friendRequest.userId)
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                            .padding()
                        }
                        
                        if !vm.friends.isEmpty {
                            Text("Friends")
                                .font(.headline)
                            
                            ForEach(vm.friends) { friend in
                                HStack {
                                    Text(friend.displayName ?? "None")
                                    
                                    Button("Remove Friend") {
                                        vm.removeFriend(userId: friend.userId)
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                            .padding()
                        }
                        
                        
                        ScrollView {
                            ForEach(vm.allUsers.sorted(by: { $0.displayName ?? "" < $1.displayName ?? "" }), id: \.userId) { user in
                                if let currentUser = settingsVM.authUser, currentUser.uid != user.userId {
                                    HStack {
                                        VStack {
                                            Text(user.displayName ?? "No Display Name")
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                            Text(user.userId)
                                                .font(.callout)
                                        }
                                        
                                        Button("Add Friend") {
                                            vm.sendFriendRequest(userId: user.userId)
                                        }
                                        .buttonStyle(.borderedProminent)
                                        
                                        Button("Cancel") {
                                            vm.cancelFriendRequest(userId: user.userId)
                                        }
                                        .buttonStyle(.bordered)
                                    }
                                    .padding()
                                }
                            }
                        }
                    }
                    
                    linkButtons
                    
                    Spacer()
                }
                .padding(.top)
            }
            .onChange(of: vm.friendRequestIds) { requestIds in
                guard let requestIds else { return }
                Task {
                    var friendRequests: [DBUser] = []
                    for id in requestIds {
                        friendRequests.append(try await vm.convertUserIdToUser(userId: id))
                    }
                    vm.friendRequests = friendRequests
                }
            }
            .onChange(of: vm.friendIds) { friendIds in
                guard let friendIds else { return }
                Task {
                    var friends: [DBUser] = []
                    for id in friendIds {
                        friends.append(try await vm.convertUserIdToUser(userId: id))
                    }
                    vm.friends = friends
                }
            }
            .onFirstAppear {
                try? vm.addListenerForUser()
            }
            .onAppear {
                settingsVM.loadAuthProviders()
                settingsVM.loadAuthUser()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "gear")
                        .font(.headline)
                        .onTapGesture {
                            showSettingsView.toggle()
                        }
                }
            }
            .sheet(isPresented: $showSettingsView) {
                SettingsView()
                    .environmentObject(settingsVM)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
        .analyticsScreen(name: "SocialTabView")
    }
}

struct SocialView_Previews: PreviewProvider {
    static var previews: some View {
        SocialTabView()
            .environmentObject(dev.homeVM)
    }
}

extension SocialTabView {
    // MARK: - Header
    var header: some View {
        HeaderView(currentTab: .constant(.social), showIcon: true)
            .padding(.horizontal)
    }
}

extension SocialTabView {
    private var linkButtons: some View {
        VStack {
            if !settingsVM.authProviders.contains(.google) {
                Button("Sign in with Google") {
                    Task {
                        do {
                            try await settingsVM.linkGoogleAccount()
                        } catch {
                            CrashlyticsManager.handleError(error: error)
                        }
                    }
                }
                .padding()
            }
            if !settingsVM.authProviders.contains(.apple) {
                Button("Sign in with Apple") {
                    Task {
                        do {
                            try await settingsVM.linkAppleAccount()
                        } catch {
                            CrashlyticsManager.handleError(error: error)
                        }
                    }
                }
                .padding()
            }
        }
    }
}
