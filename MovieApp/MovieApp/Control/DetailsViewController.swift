//
//  DetailsViewController.swift
//  MovieApp
//
//  Created by obss on 4.08.2021.
//

import UIKit
import youtube_ios_player_helper
import Kingfisher
import CoreData


protocol FavoriteDelegate {
    func didChangeFavorite()
}

class DetailsViewController: UIViewController {
    @IBOutlet weak var relaseLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var youtubePlayer: YTPlayerView!
    @IBOutlet weak var imdbLabel: UILabel!
    @IBOutlet weak var imageMovie: UIImageView!
    @IBOutlet weak var imdbView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    var movieID: Int?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var detailInfo: Detail?
    var delegate: FavoriteDelegate?
    var isFavorite: Bool = false    // This value is temporary, override the variable by using core data
    var hasFavorite: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        imageMovie.layer.cornerRadius = 10.0
        imdbView.layer.cornerRadius = 10.0
        if let safeID = movieID {
            MovieNetwork.shared.fetchMovies(with: "movie/\(safeID)", model: Detail.self) { (detail) in
                self.detailInfo = detail
                self.imdbLabel.text = String(describing: detail.imdbScore ?? 0.0)
                self.overviewLabel.text = detail.overview ?? ""
                self.relaseLabel.text = "Relase Date: \(detail.releaseDate ?? "")"
                self.imageMovie.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/original\(detail.posterPath ?? "")"), placeholder: UIImage(named: "LotrImage"))
                self.titleLabel.text = "Title: \(detail.title ?? "")"
                self.backgroundImage.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/original\(detail.backdrop ?? "")"))
                self.hasFavorite = self.hasMovie()
                if self.hasFavorite {
                    self.favoriteButton.setImage(UIImage(named: "favoriteIconFilled"), for: .normal)
                    self.isFavorite = true
                }
                MovieNetwork.shared.fetchMovies(with: "movie/\(safeID)/videos", model: Trailer.self) { (trailer) in
                    if let safeKey = trailer.results?.first?.videoKey {
                        self.youtubePlayer.load(withVideoId: safeKey)
                    }
                }
            }
        }
        
        navigationController?.navigationBar.isHidden = false
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.back(sender:)))
                self.navigationItem.leftBarButtonItem = newBackButton
        navigationItem.leftBarButtonItem = newBackButton
        // Do any additional setup after loading the view.
    }
    @objc func back(sender: UIBarButtonItem) {
        if isFavorite, !hasFavorite {
            let favoriteMovie = FavoriteMovie(context: context)
            favoriteMovie.imdbScore = detailInfo?.imdbScore ?? 0.0
            favoriteMovie.movieID = Int32(detailInfo?.movieID ?? 0)
            favoriteMovie.title = detailInfo?.title ?? ""
            favoriteMovie.imagePath = detailInfo?.posterPath ?? ""
            self.saveFavorite()
            self.delegate?.didChangeFavorite()
        } else if !isFavorite, hasFavorite {
            self.deleteFavorite()
            self.saveFavorite()
            self.delegate?.didChangeFavorite()
        }
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func addFavorite(_ sender: UIButton) {
        if !isFavorite {
            sender.setImage(UIImage(named: "favoriteIconFilled"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "favoriteIconEmpty"), for: .normal)
        }
        isFavorite = !isFavorite
    }
    // MARK: - Core Data Saving support
    func hasMovie () -> Bool {
        var result = false
        findMovie(movieID: detailInfo?.movieID) { (movie) in
            if movie != nil {
                result = true
            }
        }
        return result
    }
    func saveFavorite () {
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    func deleteFavorite () {
        findMovie(movieID: detailInfo?.movieID) { (movie) in
            if let safeMovie = movie {
                context.delete(safeMovie)
            }
        }
    }
    func findMovie (movieID: Int?,completion: (_ data: FavoriteMovie?) -> Void) {
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
}
//extension DetailsViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        <#code#>
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        <#code#>
//    }
//
//
//}
