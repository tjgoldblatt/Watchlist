//
//  Bundle+EXT.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 7/12/23.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
