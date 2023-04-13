//
//  PreviewProvider.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI
import Blackbird

extension PreviewProvider {
    static var dev: DeveloperPreview {
        return DeveloperPreview.instance
    }
}

@MainActor
class DeveloperPreview {
    static let instance = DeveloperPreview()
    
    let homeVM = HomeViewModel()
    
    let mediaMock: [DBMedia?] = [
        DBMedia(
            media: Media(mediaType: .movie,
                         id: 5,
                         originalTitle: "Batman: The Long Halloween, Part Two",
                         originalName: nil,
                         overview: "As Gotham City\'s young vigilante, the Batman, struggles to pursue a brutal serial killer, district attorney Harvey Dent gets caught in a feud involving the criminal family of the Falcones.",
                         voteAverage: 7.532,
                         voteCount: 13,
                         posterPath: "/f46QMSo2wAVY1ywrNc9yZv0rkNy.jpg",
                         backdropPath: "/ymX3MnaxAO3jJ6EQnuNBRWJYiPC.jpg",
                         genreIDS: [18],
                         popularity: nil,
                         firstAirDate: nil,
                         originCountry: nil,
                         originalLanguage: nil,
                         name: nil,
                         adult: nil,
                         releaseDate: nil,
                         title: nil,
                         video: nil,
                         profilePath: nil,
                         knownFor: nil), watched: false, personalRating: 7.0),
        
        DBMedia(
            media: Media(mediaType: .tv,
                         id: 1,
                         originalTitle: nil,
                         originalName: "Batman: The Brave and the Bold",
                         overview: "The Caped Crusader is teamed up with Blue Beetle, Green Arrow, Aquaman and countless others in his quest to uphold justice.",
                         voteAverage: 7.532,
                         voteCount: 13,
                         posterPath: "/roAoQx0TTDMCg6nXoo8ClP2TSe8.jpg",
                         backdropPath: "/roAoQx0TTDMCg6nXoo8ClP2TSe8.jpg",
                         genreIDS: [13],
                         popularity: nil,
                         firstAirDate: nil,
                         originCountry: nil,
                         originalLanguage: nil,
                         name: nil,
                         adult: nil,
                         releaseDate: nil,
                         title: nil,
                         video: nil,
                         profilePath: nil,
                         knownFor: nil),
            watched: true, personalRating: 2),
        
        DBMedia(
            media: Media(mediaType: .movie,
                         id: 5,
                         originalTitle: "Batman: The Long Halloween, Part Two",
                         originalName: nil,
                         overview: "As Gotham City\'s young vigilante, the Batman, struggles to pursue a brutal serial killer, district attorney Harvey Dent gets caught in a feud involving the criminal family of the Falcones.",
                         voteAverage: 7.532,
                         voteCount: 13,
                         posterPath: "/f46QMSo2wAVY1ywrNc9yZv0rkNy.jpg",
                         backdropPath: "/ymX3MnaxAO3jJ6EQnuNBRWJYiPC.jpg",
                         genreIDS: [18],
                         popularity: nil,
                         firstAirDate: nil,
                         originCountry: nil,
                         originalLanguage: nil,
                         name: nil,
                         adult: nil,
                         releaseDate: nil,
                         title: nil,
                         video: nil,
                         profilePath: nil,
                         knownFor: nil), watched: false, personalRating: 7.0),
        
        DBMedia(
            media: Media(mediaType: .tv,
                         id: 1,
                         originalTitle: nil,
                         originalName: "Batman: The Brave and the Bold",
                         overview: "The Caped Crusader is teamed up with Blue Beetle, Green Arrow, Aquaman and countless others in his quest to uphold justice.",
                         voteAverage: 7.532,
                         voteCount: 13,
                         posterPath: "/roAoQx0TTDMCg6nXoo8ClP2TSe8.jpg",
                         backdropPath: "/roAoQx0TTDMCg6nXoo8ClP2TSe8.jpg",
                         genreIDS: [13],
                         popularity: nil,
                         firstAirDate: nil,
                         originCountry: nil,
                         originalLanguage: nil,
                         name: nil,
                         adult: nil,
                         releaseDate: nil,
                         title: nil,
                         video: nil,
                         profilePath: nil,
                         knownFor: nil),
            watched: true, personalRating: 2),
    ]
}
