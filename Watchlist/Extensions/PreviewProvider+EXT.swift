//
//  PreviewProvider.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI

extension PreviewProvider {
    static var dev: DeveloperPreview {
        return DeveloperPreview.instance
    }
}

@MainActor
class DeveloperPreview {
    static let instance = DeveloperPreview()

    let homeVM = HomeViewModel(forPreview: true)

    let socialVM = SocialViewModel(forPreview: true)
    let settingsVM = SettingsViewModel(forPreview: true)

    let mediaMock: [DBMedia] = [
        DBMedia.sampleMovie, DBMedia.sampleTV, DBMedia.sampleMovie, DBMedia.sampleTV,
    ]
}
