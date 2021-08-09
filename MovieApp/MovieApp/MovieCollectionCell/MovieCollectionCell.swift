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
    }
    func configure(title: String?, posterPath: String?, imdb: Double?, movieID: Int?) {
        if let safeTitle = title {
            movieTitle.text = safeTitle
            if let safeImdb = imdb {
                imdbScore.text = String(describing: safeImdb)
            }
            hasMovie(movieID: movieID)
            if posterPath != nil {
                imageView.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/original\(posterPath!)"), placeholder: UIImage(named: "LotrImage"))
            }
        }
    }
    func findMovie (movieID: Int?,completion: (_ data: FavoriteMovie?) -> Void){
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        if let safeID = movieID {
            request.predicate = NSPredicate(format: "movieID == \(safeID)")
            do {
                try completion(context.fetch(request).first)
                } catch {
                print(error.localizedDescription)
            }
        }
    }
    func hasMovie (movieID : Int?) {
        var result = false
        findMovie(movieID: movieID) { (movie) in
            if movie != nil {
                self.favoriteIcon.image = UIImage(named: "favoriteIconFilled")
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
