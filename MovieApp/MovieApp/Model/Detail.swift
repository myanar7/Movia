//
//  Detail.swift
//  MovieApp
//
//  Created by obss on 6.08.2021.
//

import Foundation

struct Detail: Decodable {
    let title: String?
    let releaseDate: String?
    let posterPath: String?
    let movieID: Int?
    let overview: String?
    let imdbScore: Double?
    let backdrop: String?
    let budget: Int?
    let genres: [Genre]?
    enum CodingKeys: String, CodingKey {
        case title, overview, budget, genres
        case movieID = "id"
        case imdbScore = "vote_average"
        case backdrop = "backdrop_path"
        case releaseDate = "release_date"
        case posterPath = "poster_path"
    }
}
struct Genre: Decodable {
    let name: String?
}
