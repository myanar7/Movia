//
//  MovieCollectionCell.swift
//  MovieApp
//
//  Created by obss on 1.08.2021.
//

import UIKit
import Kingfisher
import CoreData
class MovieCollectionCell: UICollectionViewCell {

    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var outerCardView: UIView!
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var imdbScore: UILabel!
    @IBOutlet weak var imdbBackground: UIView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func awakeFromNib() {
        super.awakeFromNib()
        imdbBackground.layer.cornerRadius = imdbBackground.frame.width/5
        outerCardView.roundedView()
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = outerCardView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        outerCardView.insertSubview(blurEffectView, at: 0)
    }
    func configure(title: String?, posterPath: String?, imdb: Double?, movieID: Int?) {
        if let safeTitle = title {
            movieTitle.text = safeTitle
            if let safeImdb = imdb {
                imdbScore.text = String(describing: safeImdb)
            }
            hasMovie(movieID: movieID)
            if posterPath != nil {
                imageView.kf.setImage(with: URL(string: "\(Constants.Network.imageURL)\(posterPath!)"), placeholder: UIImage(named: Constants.Assets.placeholderImage))
            } else {
                imageView.image = UIImage(named: Constants.Assets.placeholderImage)
            }
        }
    }
    func findMovie (movieID: Int?, completion: (_ data: FavoriteMovie?) -> Void) {
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        if let safeID = movieID {
            request.predicate = NSPredicate(format: Constants.CoreData.predicate(with: safeID))
            do {
                try completion(context.fetch(request).first)
                } catch {
                print(error.localizedDescription)
            }
        }
    }
    func hasMovie (movieID: Int?) {
        findMovie(movieID: movieID) { (movie) in
            if movie != nil {
                self.favoriteIcon.image = UIImage(named: Constants.Assets.isFavoriteImage)
            } else {
                self.favoriteIcon.image = UIImage()
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
