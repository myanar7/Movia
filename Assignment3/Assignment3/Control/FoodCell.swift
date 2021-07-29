//
//  FoodCell.swift
//  Assignment3
//
//  Created by obss on 29.07.2021.
//

import UIKit
import Kingfisher

class FoodCell: UITableViewCell {

    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet var foodImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func configure(foodName : String?, calories : Double?, imageUrl : String?){
        foodNameLabel.text = foodName
        caloriesLabel.text = String(describing: calories ?? 0.0) + " kcal"
        foodImage.kf.setImage(with: URL(string: imageUrl ?? ""))
    }
    
}
