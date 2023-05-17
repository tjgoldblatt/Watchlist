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
        try! DBMedia(
            media: Media(
                mediaType: .movie,
                id: 736_074,
                originalTitle: "Batman: The Long Halloween, Part Two",
                originalName: nil,
                overview: "As Gotham City\'s young vigilante, the Batman, struggles to pursue a brutal serial killer, district attorney Harvey Dent gets caught in a feud involving the criminal family of the Falcones.",
                voteAverage: 7.532,
                voteCount: 13,
                posterPath: "/f46QMSo2wAVY1ywrNc9yZv0rkNy.jpg",
                backdropPath: "/ymX3MnaxAO3jJ6EQnuNBRWJYiPC.jpg",
                genreIDS: [18],
                releaseDate: "2021-10-1",
                title: "Batman: The Long Halloween, Part Two"),
            watched: false,
            personalRating: 7.0),

        try! DBMedia(
            media: Media(
                mediaType: .tv,
                id: 15804,
                originalTitle: nil,
                originalName: "Batman: The Brave and the Bold",
                overview: "The Caped Crusader is teamed up with Blue Beetle, Green Arrow, Aquaman and countless others in his quest to uphold justice.",
                voteAverage: 7.532,
                voteCount: 13,
                posterPath: "/roAoQx0TTDMCg6nXoo8ClP2TSe8.jpg",
                backdropPath: "/roAoQx0TTDMCg6nXoo8ClP2TSe8.jpg",
                genreIDS: [13],
                firstAirDate: "2021-10-1",
                name: "Batman: The Brave and the Bold"),
            watched: true,
            personalRating: 2),

        try! DBMedia(
            media: Media(
                mediaType: .movie,
                id: 736_074,
                originalTitle: "Batman: The Long Halloween, Part Two",
                originalName: nil,
                overview: "As Gotham City\'s young vigilante, the Batman, struggles to pursue a brutal serial killer, district attorney Harvey Dent gets caught in a feud involving the criminal family of the Falcones.",
                voteAverage: 7.532,
                voteCount: 13,
                posterPath: "/f46QMSo2wAVY1ywrNc9yZv0rkNy.jpg",
                backdropPath: "/ymX3MnaxAO3jJ6EQnuNBRWJYiPC.jpg",
                genreIDS: [18],
                releaseDate: "2021-10-1",
                title: "Batman: The Long Halloween, Part Two"),
            watched: false,
            personalRating: 7.0),

        try! DBMedia(
            media: Media(
                mediaType: .tv,
                id: 15804,
                originalTitle: nil,
                originalName: "Batman: The Brave and the Bold",
                overview: "The Caped Crusader is teamed up with Blue Beetle, Green Arrow, Aquaman and countless others in his quest to uphold justice.",
                voteAverage: 7.532,
                voteCount: 13,
                posterPath: "/roAoQx0TTDMCg6nXoo8ClP2TSe8.jpg",
                backdropPath: "/roAoQx0TTDMCg6nXoo8ClP2TSe8.jpg",
                genreIDS: [13],
                firstAirDate: "2021-10-1",
                name: "Batman: The Brave and the Bold"),
            watched: true,
            personalRating: 2),
    ]
}
