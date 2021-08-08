//
//  DetailsViewController.swift
//  MovieApp
//
//  Created by obss on 4.08.2021.
//

import UIKit
import youtube_ios_player_helper
import Kingfisher

class DetailsViewController: UIViewController {
    @IBOutlet weak var relaseLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var youtubePlayer: YTPlayerView!
    @IBOutlet weak var imdbLabel: UILabel!
    @IBOutlet weak var imageMovie: UIImageView!
    @IBOutlet weak var imdbView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    var movieID: Int?
//    var detailInfo: Detail?
    override func viewDidLoad() {
        super.viewDidLoad()
        imageMovie.layer.cornerRadius = 10.0
        imdbView.layer.cornerRadius = 10.0
        if let safeID = movieID {
            MovieNetwork.shared.fetchMovies(with: "movie/\(safeID)", model: Detail.self) { (detail) in
                self.imdbLabel.text = String(describing: detail.imdbScore ?? 0.0)
                self.overviewLabel.text = detail.overview ?? ""
                self.relaseLabel.text = "Relase Date: \(detail.releaseDate ?? "")"
                self.imageMovie.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/original\(detail.posterPath ?? "")"), placeholder: UIImage(named: "LotrImage"))
                self.titleLabel.text = "Title: \(detail.title ?? "")"
                self.backgroundImage.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/original\(detail.backdrop ?? "")"))
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
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func addFavorite(_ sender: UIButton) {
        if sender.currentImage == UIImage(named: "favoriteIconEmpty") {
            sender.setImage(UIImage(named: "favoriteIconFilled"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "favoriteIconEmpty"), for: .normal)
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
