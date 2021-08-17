//
//  MovieNetwork.swift
//  MovieApp
//
//  Created by obss on 1.08.2021.
//

import Foundation
import Alamofire

struct MovieNetwork {

    static var shared = MovieNetwork()
    var isPaging = false
    let baseUrl = "https://api.themoviedb.org/3/"

    func fetchMovies<T>(with type: String? = "movie/popular", page: Int = 1, query: String? = nil, model: T.Type, completion : @escaping (T?, AFError?) -> Void) where T: Decodable {
        var apiParameter = ["api_key": Constants.Network.apiKey, "language": Locale.current.languageCode]
        if page != 1 {apiParameter["page"] = String(describing: page)}
        if query != nil {apiParameter["query"] = query}
        var safeType = "movie/popular"
        if type != nil {safeType = type!}
        AF.request("\(baseUrl)\(safeType)?", parameters: apiParameter).response { (response) in
            if response.error == nil, let safeData = response.data {
                do {
                    let decodedData = try JSONDecoder().decode(model, from: safeData)
                    completion(decodedData, nil)
                } catch {
                    completion(nil, error.asAFError)
                }
            } else {
                completion(nil, response.error)
            }
        }
    }
    mutating func setPaging(with value: Bool) {
        isPaging = value
    }

}
