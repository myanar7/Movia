//
//  MovieCollectionCell.swift
//  MovieApp
//
//  Created by obss on 1.08.2021.
//

import UIKit
import Kingfisher

class MovieCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(title : String?, posterPath: String?){
        if let safeTitle = title {
            movieTitle.text = safeTitle
            guard let url = URL.init(string: "https://image.tmdb.org/t/p/w500\(posterPath!))") else {
                return
            }
            let resource = ImageResource(downloadURL: url)
            
            KingfisherManager.shared.retrieveImage(with : resource) { result in
                switch result {
                case .success(let value):
                        self.imageView.image = value.image
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }

}
