//
//  FoodNetwork.swift
//  Assignment3
//
//  Created by obss on 29.07.2021.
//

import Foundation
import Alamofire

protocol FoodNetworkDelegate {
    func didDataReceived(data : FoodResult)
}

class FoodNetwork {
    
    static let shared = FoodNetwork()
    
    let baseUrl = "https://api.spoonacular.com/recipes/complexSearch?number=15&minCalories=0&apiKey=7a6d723c994042028f7bea0e521f9404"
    
    var delegate : FoodNetworkDelegate?
    
    
    func fetchData(foodName : String?){
        if let foodName = foodName{
            AF.request("\(baseUrl)&query=\(foodName)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil).response { (responseData) in
                print("Response içinde")
                guard let data = responseData.data else {return}
                do{
                    let foods = try JSONDecoder().decode(FoodResult.self, from: data)
                    self.delegate?.didDataReceived(data: foods)
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    
}
