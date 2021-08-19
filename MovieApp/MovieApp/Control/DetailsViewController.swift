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

protocol FavoriteDelegate: AnyObject {
    func didChangeFavorite()
}

class DetailsViewController: UIViewController {
    @IBOutlet weak var relaseLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var youtubePlayer: YTPlayerView!
    @IBOutlet weak var imdbLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var imageMovie: UIImageView!
    @IBOutlet weak var imdbView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    var movieID: Int?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var detailInfo: Detail?
    weak var delegate: FavoriteDelegate?
    var isFavorite: Bool = false    // This value is temporary, override the variable by using core data
    var hasFavorite: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViews()
        configureDetailPage()
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func customizeViews () {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = indicatorView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicatorView.insertSubview(blurEffectView, at: 0)
        activityIndicator.startAnimating()
        imageMovie.layer.cornerRadius = 10.0
        imdbView.layer.cornerRadius = 10.0
        navigationController?.navigationBar.isHidden = false
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        navigationItem.leftBarButtonItem = newBackButton
    }
    func configureDetailPage () {
        if let safeID = movieID {
            MovieNetwork.shared.fetchMovies(with: Constants.Network.detailUrl(with: safeID), model: Detail.self) { (data, error) in
                if let safeData = data, safeData.success == nil {
                    self.detailInfo = safeData
                    self.hideViewIfNeedsDouble(double: safeData.imdbScore, label: self.imdbLabel)
                    self.hideViewIfNeedsString(string: safeData.overview, label: self.overviewLabel)
                    self.hideViewIfNeedsString(string: self.dateFormat(date: safeData.releaseDate), label: self.relaseLabel)
                    self.hideViewIfNeedsInt(integer: safeData.budget, label: self.budgetLabel)
                    self.hideViewIfNeedsDouble(double: safeData.popularity, label: self.popularityLabel)
                    self.hideViewIfNeedsString(string: safeData.status, label: self.statusLabel)
                    self.hideViewIfNeedsString(string: safeData.title, label: self.titleLabel)
                    self.genresLabel.text = self.genres(genres: safeData.genres ?? [])
                    self.imageMovie.kf.setImage(with: URL(string: "\(Constants.Network.imageURL)\(safeData.posterPath ?? "")"), placeholder: UIImage(named: Constants.Assets.placeholderImage))
                    self.backgroundImage.kf.setImage(with: URL(string: "\(Constants.Network.imageURL)\(safeData.backdrop ?? "")"))
                    self.hasFavorite = self.hasMovie()
                    if self.hasFavorite {
                        self.favoriteButton.setImage(UIImage(named: Constants.Assets.isFavoriteImage), for: .normal)
                        self.isFavorite = true
                    }
                    MovieNetwork.shared.fetchMovies(with: Constants.Network.videoUrl(with: safeID), model: Trailer.self) { (trailer, _) in
                        if let safeTrailer = trailer, let safeKey = safeTrailer.results?.first?.videoKey {
                            self.youtubePlayer.load(withVideoId: safeKey)
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.activityIndicator.stopAnimating()
                        self.indicatorView.isHidden = true
                    }
                } else {
                    self.didCrashed(error: error)
                }
            }
        }
    }
    func setHiddenLabel (label: UILabel?) {
        label?.superview?.isHidden = true
    }
    func hideViewIfNeedsString (string: String?, label: UILabel?) {
        if let safeString = string, safeString != "" { // If the value nil then does not appear
            label?.text = safeString
        } else {setHiddenLabel(label: label)}
    }
    func hideViewIfNeedsInt (integer: Int?, label: UILabel?) {
        if let safeInteger = integer, safeInteger != 0 { // If the value nil then does not appear
            label?.text = numberFormat(number: NSNumber(value: safeInteger))
        } else {setHiddenLabel(label: label)}
    }
    func hideViewIfNeedsDouble (double: Double?, label: UILabel?) {
        if let safeDouble = double, safeDouble != 0.0 { // If the value nil then does not appear
            label?.text = numberFormat(number: NSNumber(value: safeDouble))
        } else {setHiddenLabel(label: label)}
    }
    func numberFormat (number: NSNumber) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        return fmt.string(from: number) ?? "--"
    }
    func dateFormat (date: String?) -> String {
        if let safeDate = date {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd"

            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMM dd,yyyy"

            if let date = dateFormatterGet.date(from: safeDate) {
                return dateFormatterPrint.string(from: date)
            } else {
               print("There was an error decoding the string")
            }
        }
        return ""
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
    func genres (genres: [Genre]) -> String {
        var allGenres: String = ""
        for genre in genres {
            allGenres += "\(genre.name ?? "") "
        }
        return allGenres
    }
    @IBAction func addFavorite(_ sender: UIButton) {
        if !isFavorite {
            sender.setImage(UIImage(named: Constants.Assets.isFavoriteImage), for: .normal)
        } else {
            sender.setImage(UIImage(named: Constants.Assets.isNotFavoriteImage), for: .normal)
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
}
