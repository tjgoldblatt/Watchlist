//
//  MockService.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 5/25/23.
//

import Foundation

enum MockService {
    static var mockTVList: [DBMedia] {
        [mockTV_1, mockTV_2]
    }

    static var mockMovieList: [DBMedia] {
        [mockMovie_1, mockMovie_2]
    }

    static var mockMovie_1: DBMedia {
        try! DBMedia(
            media: Media(
                mediaType: .movie,
                id: 37799,
                originalTitle: "The Social Network",
                originalName: nil,
                overview: "The tale of a new breed of cultural insurgent: a punk genius who sparked a revolution and changed the face of human interaction for a generation, and perhaps forever.",
                voteAverage: 7.35,
                voteCount: 10859,
                posterPath: "/n0ybibhJtQ5icDqTp8eRytcIHJx.jpg",
                backdropPath: "/2BNKxbq4muNcwTjSDNCYnvr1dM8.jpg",
                genreIDS: [18],
                firstAirDate: "2010-09-24",
                name: nil,
                title: "The Social Network"
            ),
            watched: true,
            personalRating: 9
        )
    }

    static var mockMovie_2: DBMedia {
        try! DBMedia(
            media: Media(
                mediaType: .movie,
                id: 16869,
                originalTitle: "Inglourious Basterds",
                originalName: nil,
                overview: "In Nazi-occupied France during World War II, a group of Jewish-American soldiers known as \"The Basterds\" are chosen specifically to spread fear throughout the Third Reich by scalping and brutally killing Nazis. The Basterds, lead by Lt. Aldo Raine soon cross paths with a French-Jewish teenage girl who runs a movie theater in Paris which is targeted by the soldiers.",
                voteAverage: 8.215,
                voteCount: 20214,
                posterPath: "/7sfbEnaARXDDhKm0CZ7D7uc2sbo.jpg",
                backdropPath: "/hg0MTIFs49ef179C9Y1HRtzqbbK.jpg",
                genreIDS: [18, 53, 10752],
                releaseDate: "2009-08-19",
                title: "Inglourious Basterds"
            ),
            watched: false,
            personalRating: nil
        )
    }

    static var mockTV_1: DBMedia {
        try! DBMedia(
            media: Media(
                mediaType: .tv,
                id: 1399,
                originalTitle: nil,
                originalName: "Game of Thrones",
                overview: "Seven noble families fight for control of the mythical land of Westeros. Friction between the houses leads to full-scale war. All while a very ancient evil awakens in the farthest north. Amidst the war, a neglected military order of misfits, the Night\'s Watch, is all that stands between the realms of men and icy horrors beyond.",
                voteAverage: 8.436,
                voteCount: 21141,
                posterPath: "/7WUHnWGx5OO145IRxPDUkQSh4C7.jpg",
                backdropPath: "/6LWy0jvMpmjoS9fojNgHIKoWL05.jpg",
                genreIDS: [10765, 18, 10759],
                firstAirDate: "2011-04-17",
                name: "Game of Thrones"
            ),
            watched: false,
            personalRating: nil
        )
    }

    static var mockTV_2: DBMedia {
        try! DBMedia(
            media: Media(
                mediaType: .tv,
                id: 1438,
                originalTitle: nil,
                originalName: "The Wire",
                overview: "Told from the points of view of both the Baltimore homicide and narcotics detectives and their targets, the series captures a universe in which the national war on drugs has become a permanent, self-sustaining bureaucracy, and distinctions between good and evil are routinely obliterated.",
                voteAverage: 8.504,
                voteCount: 1792,
                posterPath: "/4lbclFySvugI51fwsyxBTOm4DqK.jpg",
                backdropPath: "/oggnxmvofLtGQvXsO9bAFyCj3p6.jpg",
                genreIDS: [80, 18],
                firstAirDate: "2002-06-02",
                name: "The Wire"
            ),
            watched: true,
            personalRating: 9
        )
    }
}
