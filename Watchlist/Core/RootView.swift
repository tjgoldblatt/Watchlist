//
//  RootView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/20/23.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var vm: HomeViewModel
    @EnvironmentObject var authVM: AuthenticationViewModel
    
    @State var showDisplayNameView: Bool = false
    
    var body: some View {
        ZStack {
            if !vm.showSignInView {
                HomeView()
                    .onFirstAppear {
                        try? vm.addListenerForMedia()
                    }
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            vm.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $vm.showSignInView, onDismiss: {
            vm.selectedTab = .movies
            Task {
                let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
                
                if authUser?.isAnonymous == false {
                    if try await UserManager.shared.getDisplayNameForUser() == nil {
                        showDisplayNameView.toggle()
                    }
                }
            }
        }) {
            NavigationStack {
                SignInView(showSignInView: $vm.showSignInView)
                    .environmentObject(authVM)
            }
        }
        .fullScreenCover(isPresented: $showDisplayNameView) {
            DisplayNameView()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
