//
//  ViewController.swift
//  MovieApp
//
//  Created by obss on 30.07.2021.
//

import UIKit

class ViewController: UIViewController {

    var populerMovies: [Result] = []

    @IBOutlet weak var contentViewTopConstaint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            cellHeight = collectionView.frame.height/3
        }
    }
    var cellHeight : CGFloat = 0.0
    
    @IBOutlet weak var searchField: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        configurePage()
        getMovies()
    }
    func getMovies() {
        MovieNetwork.shared.fetchMovies { (data) in

            if let movies = data.results {
                self.populerMovies = movies
                self.collectionView.reloadData()
            }
        }
    }
    func configurePage() {
        searchField.searchTextField.delegate = self
        navigationController?.navigationBar.isHidden = true
        collectionView.backgroundColor = UIColor(patternImage: UIImage())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: Constants.Nibs.movieCollectionCell, bundle: nil), forCellWithReuseIdentifier: Constants.Nibs.movieCollectionCell)
        collectionView.setCollectionViewLayout(UICollectionViewFlowLayout(), animated: true)
    }
}
extension ViewController: UISearchTextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        MovieNetwork.shared.fetchMovies(with: "search/movie", query: textField.text) { (movie) in
            self.populerMovies = movie.results ?? []
            self.collectionView.reloadData()
        }
    }
}
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y
        if scrollOffset < cellHeight+10,scrollView.contentOffset.y > cellHeight-10 || scrollOffset == 0.0{
            self.contentViewTopConstaint.constant =  -scrollView.contentOffset.y
            UIView.animate(withDuration: 3.0) {
                self.view.layoutIfNeeded()
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return populerMovies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Nibs.movieCollectionCell, for: indexPath) as! MovieCollectionCell
        let data = populerMovies[indexPath.row]
        cell.configure(title: data.title, posterPath: data.posterPath)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MovieCollectionCell
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: Constants.Routes.detailsPage) as! DetailsViewController
        detailsVC.imageCell = cell.imageView.image
        detailsVC.titleCell = cell.movieTitle.text
        navigationController?.pushViewController(detailsVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width*0.31, height: collectionView.frame.height/3)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }

    func collectionView(_ collectionView: UICollectionView, layout
                            collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}
