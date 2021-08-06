//
//  Movie.swift
//  MovieApp
//
//  Created by obss on 2.08.2021.
//

import Foundation

struct Movie: Decodable {
    let results: [Result]?
}
struct Result: Codable {
    let title: String?
    let releaseDate: String?
    let posterPath: String?
    let movieID: Int?

    enum CodingKeys: String, CodingKey {
        case title
        case movieID = "id"
        case releaseDate = "release_date"
        case posterPath = "poster_path"
    }
}
