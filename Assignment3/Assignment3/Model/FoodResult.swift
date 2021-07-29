//
//  Food.swift
//  Assignment3
//
//  Created by obss on 29.07.2021.
//

import Foundation

struct FoodResult : Decodable {
    let results : [Food]
}
struct Food : Decodable {
    let title : String
    let image : String
    let nutrition : Nutrition
}
struct Nutrition : Decodable{
    let nutrients : [Nutrient]
}
struct Nutrient : Decodable {
    let amount : Double
}
