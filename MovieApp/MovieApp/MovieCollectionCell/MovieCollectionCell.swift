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
    @IBOutlet weak var outerCardView: UIView!
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var imdbScore: UILabel!
    @IBOutlet weak var imdbBackground: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imdbBackground.layer.cornerRadius = imdbBackground.frame.width/5
        outerCardView.roundedView()
    }
    func configure(title: String?, posterPath: String?, imdb: Double?) {
        if let safeTitle = title {
            movieTitle.text = safeTitle
            if let safeImdb = imdb {
                imdbScore.text = String(describing: safeImdb)
            }
            if posterPath != nil {
                imageView.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/original\(posterPath!)"), placeholder: UIImage(named: "LotrImage"))
            }
        }
    }
}
extension UIView {
    func roundedView() {
        let maskPath1 = UIBezierPath(roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
}
