//
//  DebugView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 5/2/23.
//

import SwiftUI

struct DebugView: View {
	@State var currentUser: DBUser?
    
    var body: some View {
        List {
			if let currentUser {
				Text("User ID: \n" + currentUser.userId)
				Text("Display Name: \n" + (currentUser.displayName ?? "No display name"))
				Text("Date Created: \n" + (currentUser.dateCreated?.dateValue().formatted() ?? ""))
				Text("Friend Requests: \n" + (currentUser.friendRequests?.description ?? ""))
				Text("Friends: \n" + (currentUser.friends?.description ?? ""))
			}
		}
		.onAppear {
			Task {
				currentUser = try? await UserManager.shared.getUser()
			}
		}
    }
}

struct DebugView_Previews: PreviewProvider {
	static let testUser = SocialViewModel(forPreview: true).currentUser
	
    static var previews: some View {
        DebugView(currentUser: testUser)
    }
}
