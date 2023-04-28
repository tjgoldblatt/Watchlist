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
    
    @StateObject var vm: SocialViewModel
    @StateObject private var settingsVM: SettingsViewModel
    
    init(vm: SocialViewModel = SocialViewModel(), settingsVM: SettingsViewModel = SettingsViewModel()) {
        _vm = StateObject(wrappedValue: vm)
        _settingsVM = StateObject(wrappedValue: settingsVM)
    }
    
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
                    }
                    
                    linkButtons
                    
                    Spacer()
                }
                .padding(.top)
            }
            .onChange(of: vm.friendRequestIds) { requestIds in
                guard let requestIds else { return }
                homeVM.pendingFriendRequests = requestIds.count
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
        SocialTabView(vm: dev.socialVM, settingsVM: dev.settingsVM)
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
