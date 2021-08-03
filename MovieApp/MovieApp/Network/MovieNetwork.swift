//
//  MovieNetwork.swift
//  MovieApp
//
//  Created by obss on 1.08.2021.
//

import Foundation
import Alamofire

struct MovieNetwork {
    
    static let shared = MovieNetwork()
    
    let baseUrl = "https://api.themoviedb.org/3/"
    
    func fetchMovies(with type : String = "movie/popular",query : String? = nil,completion : @escaping (Movie) -> Void){
        var apiParameter = ["api_key" : Constants.Network.apiKey]
        if query != nil {apiParameter["query"] = query}
        AF.request("\(baseUrl)\(type)?", parameters: apiParameter).response { (response) in
            print(response.request?.url)
            if response.error == nil ,let safeData = response.data {
                do {
                    let decodedData = try JSONDecoder().decode(Movie.self, from: safeData)
                    completion(decodedData)
                } catch {
                    print(error.localizedDescription)
                }
                
            }
            
        }
    }
}
