//
//  DetailsViewController.swift
//  MovieApp
//
//  Created by obss on 4.08.2021.
//

import UIKit
import youtube_ios_player_helper

class DetailsViewController: UIViewController {
    @IBOutlet weak var imdbLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var youtubePlayer: YTPlayerView!
    @IBOutlet weak var imageMovie: UIImageView!
    var imageCell: UIImage?
    var titleCell: String?
    var movieID: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let safeID = movieID {
            MovieNetwork.shared.fetchMovies(with: "movie/\(safeID)", model: Detail.self) { (detail) in
                self.overviewLabel.text = detail.overview
                self.imdbLabel.text = detail.releaseDate
                MovieNetwork.shared.fetchMovies(with: "movie/\(safeID)/videos", model: Trailer.self) { (trailer) in
                    if let safeKey = trailer.results?.first?.videoKey{
                        self.youtubePlayer.load(withVideoId: safeKey)
                    }
                }
            }
        }
        //youtubePlayer.load(withVideoId: "lV4YY5EIFOI")
        imageMovie.image = imageCell
        titleLabel.text = titleCell
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
