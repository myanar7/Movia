//
//  Trailer.swift
//  MovieApp
//
//  Created by obss on 6.08.2021.
//

import Foundation

struct Trailer: Decodable {
    let results: [VideoKey]?
}
struct VideoKey: Decodable {
    let videoKey: String?
    enum CodingKeys: String, CodingKey {
        case videoKey = "key"
    }
}
