//
//  FavoriteViewController.swift
//  MovieApp
//
//  Created by obss on 1.08.2021.
//

import UIKit
import CoreData
class FavoriteViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var favoriteMovies: [FavoriteMovie] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePage()
        getFavoriteMovies()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getFavoriteMovies() // BURADA Bİ ŞEYLER DEĞİŞMELİ HER GEÇİŞTE LOAD ETMESİ GEREKSİZ
        collectionView.reloadData()
    }
    func getFavoriteMovies () {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        do {
            favoriteMovies = try context.fetch(request)
            collectionView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    func configurePage () {
        collectionView.backgroundColor = UIColor(patternImage: UIImage())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: Constants.Nibs.movieCollectionCell, bundle: nil), forCellWithReuseIdentifier: Constants.Nibs.movieCollectionCell)
        collectionView.setCollectionViewLayout(UICollectionViewFlowLayout(), animated: true)
    }
}
// MARK: - Collection View Protocols
extension FavoriteViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteMovies.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Nibs.movieCollectionCell, for: indexPath) as! MovieCollectionCell
        let data = favoriteMovies[indexPath.row]
        cell.configure(title: data.title, posterPath: data.imagePath, imdb: data.imdbScore, movieID: Int(data.movieID))
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Routes.detailsPage) as! DetailsViewController
        detailsVC.delegate = self
        detailsVC.movieID = Int(favoriteMovies[indexPath.row].movieID)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width*0.46, height: collectionView.frame.height/3)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    func collectionView(_ collectionView: UICollectionView, layout
                            collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return view.frame.height/40.0
    }
}
// MARK: - Favorite Delegate
extension FavoriteViewController: FavoriteDelegate {
    func didChangeFavorite() {
        collectionView.reloadData()
    }
}
