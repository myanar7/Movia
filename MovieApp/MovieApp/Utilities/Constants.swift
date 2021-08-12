//
//  Constants.swift
//  MovieApp
//
//  Created by obss on 30.07.2021.
//

import Foundation

struct Constants {

    struct Network {
        static let apiKey = "71d98b08f7e35fae8bdf6f14d6c2f67d"
        static let searchingParameter = "search/movie"
        static let imageURL = "https://image.tmdb.org/t/p/w500"
        static func detailUrl (with movieID: Int) -> String {
            return "movie/\(movieID)"
        }
        static func videoUrl (with movieID: Int) -> String {
            return "movie/\(movieID)/videos"
        }
    }
    struct AppInfo {
        static let appName = "Movie"
    }
    struct Assets {
        static let placeholderImage = "placeholderImage"
        static let isFavoriteImage = "favoriteIconFilled"
        static let isNotFavoriteImage = "favoriteIconEmpty"
    }
    struct Nibs {
        static let movieCollectionCell = "MovieCollectionCell"
        static let categoryCell = "CategoryCell"
    }
    struct ColorPalette {
        static let backgroundColor = "backgroundColor"
        static let mediumColor = "mediumColor"
        static let titleColor = "titleColor"
        static let barColor = "barColor"
    }
    struct Routes {
        static let detailsPage = "DetailsViewController"
    }
    struct CoreData {
        static func predicate (with movieID: Int) -> String {
            return "movieID == \(movieID)"
        }
    }
}
