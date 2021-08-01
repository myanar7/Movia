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
    
    let baseUrl = "https://api.themoviedb.org/3/movie/"
    
    func fetchMovies(with type : String = "popular",completion : @escaping (Movie) -> Void){
        AF.request("\(baseUrl)\(type)?", parameters: ["api_key" : Constants.Network.apiKey]).response { (response) in
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
