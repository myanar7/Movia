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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var youtubePlayer: YTPlayerView!
    @IBOutlet weak var imageMovie: UIImageView!
    var imageCell: UIImage?
    var titleCell: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        //youtubePlayer.load(withVideoId: "lV4YY5EIFOI")
        imageMovie.image = imageCell
        titleLabel.text = titleCell
        navigationController?.navigationBar.isHidden = false
        // Do any additional setup after loading the view.
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
