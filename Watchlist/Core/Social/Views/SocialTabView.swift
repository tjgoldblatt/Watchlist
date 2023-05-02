//
//  SocialTabView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/11/23.
//

import SwiftUI
import FirebaseFirestoreSwift
import NukeUI

struct SocialTabView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    
    @StateObject var vm: SocialViewModel
    @StateObject private var settingsVM: SettingsViewModel
    
    init(forPreview: Bool = false) {
        _vm = StateObject(wrappedValue: SocialViewModel(forPreview: forPreview))
        _settingsVM = StateObject(wrappedValue: SettingsViewModel(forPreview: forPreview))
    }
    
    @State var showSettingsView: Bool = false
    @State var showAddFriendsView: Bool = false
    @State var filterText: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                VStack(spacing: 10) {
                    header
                    
                    AddFriendsFilterView(filterText: $filterText)
                        .padding(.horizontal)
                    
                    ScrollView {
                        if settingsVM.authUser?.isAnonymous == false {
                            
                            friendRequests
                            
                            friends
                        } else {
                            linkButtons
                        }
                        
                        Spacer()
                    }
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
            .onAppear {
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "gear")
                        .font(.headline)
                        .foregroundColor(Color.theme.text)
                        .onTapGesture {
                            showSettingsView.toggle()
                        }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundColor(Color.theme.text)
                        .onTapGesture {
                            showAddFriendsView.toggle()
                        }
                }
            }
            .sheet(isPresented: $showSettingsView) {
                SettingsView()
                    .environmentObject(settingsVM)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showAddFriendsView) {
                AddFriendsView()
                    .environmentObject(settingsVM)
                    .environmentObject(homeVM)
                    .environmentObject(vm)
                    .presentationDetents([.large])
            }
        }
        .analyticsScreen(name: "SocialTabView")
    }
}

struct SocialView_Previews: PreviewProvider {
    static var previews: some View {
        SocialTabView(forPreview: true)
            .environmentObject(dev.homeVM)
    }
}

extension SocialTabView {
    // MARK: - Header
    private var header: some View {
        HeaderView(currentTab: .constant(.social), showIcon: true)
            .padding(.horizontal)
    }
    
    private var friendRequests: some View {
        VStack {
            if !vm.friendRequests.isEmpty {
                HStack {
                    Text("Friend Requests")
                        .font(.title3)
                        .fontWeight(.medium)
                    Spacer()
                }
                
                VStack {
                    ForEach(vm.friendRequests) { friendRequest in
                        HStack {
                            LazyImage(url: URL(string: friendRequest.photoUrl ?? "")) { state in
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
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .padding(.trailing)
                            
                            VStack(alignment: .leading) {
                                Text(friendRequest.displayName ?? "None")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                HStack {
                                    Button("Accept") {
                                        vm.acceptFriendRequest(userId: friendRequest.userId)
                                    }
                                    .foregroundColor(Color.theme.genreText)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .frame(height: 30)
                                    .frame(minWidth: 100)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.theme.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .fixedSize(horizontal: true, vertical: false)
                                    
                                    Button("Decline") {
                                        vm.declineFriendRequest(userId: friendRequest.userId)
                                    }
                                    .foregroundColor(Color.theme.red)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .frame(height: 30)
                                    .frame(minWidth: 100)
                                    .background(Color.theme.secondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .fixedSize(horizontal: true, vertical: false)
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                
                            }
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .padding()
    }
    
    private var friends: some View {
        VStack {
            if !vm.friends.isEmpty {
                HStack {
                    Text("Friends")
                        .font(.title3)
                        .fontWeight(.medium)
                    Spacer()
                }
                
                ForEach(vm.friends) { friend in
                    HStack {
                        LazyImage(url: URL(string: friend.photoUrl ?? "")) { state in
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
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .padding(.trailing)
                        
                        VStack(alignment: .leading) {
                            Text(friend.displayName ?? "None")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Button("Remove Friend") {
                                vm.removeFriend(userId: friend.userId)
                            }
                            .foregroundColor(Color.theme.genreText)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(height: 40)
                            .frame(minWidth: 120)
                            .frame(maxWidth: .infinity)
                            .background(Color.theme.red)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .fixedSize(horizontal: true, vertical: false)
                            
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
        }
        .padding()
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
