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

    func fetchMovies<T>(with type: String = "movie/popular", page: Int = 1, query: String? = nil, model: T.Type, completion : @escaping (T) -> Void) where T: Decodable {
        var apiParameter = ["api_key": Constants.Network.apiKey]
        if page != 1 {apiParameter["page"] = String(describing: page)}
        if query != nil {apiParameter["query"] = query}
        AF.request("\(baseUrl)\(type)?", parameters: apiParameter).response { (response) in
            if response.error == nil, let safeData = response.data {
                do {
                    let decodedData = try JSONDecoder().decode(model, from: safeData)
                    completion(decodedData)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    mutating func setPaging(with value: Bool){
        isPaging = value
    }

}
