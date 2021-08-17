//
//  Movie.swift
//  MovieApp
//
//  Created by obss on 2.08.2021.
//

import Foundation

struct Movie: Decodable {
    let results: [Result]?
    let success: Bool?
}
struct Result: Codable {
    let title: String?
    let posterPath: String?
    let imdbScore: Double?
    let movieID: Int?

    enum CodingKeys: String, CodingKey {
        case title
        case imdbScore = "vote_average"
        case movieID = "id"
        case posterPath = "poster_path"
    }
}
