//
//  ViewController.swift
//  MovieApp
//
//  Created by obss on 30.07.2021.
//

import UIKit

class ViewController: UIViewController {
    var populerMovies: [Result] = []
    var isHeaderHidden = false
    var currentPage = 1
    @IBOutlet weak var contentViewTopConstaint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            cellHeight = collectionView.frame.height/3
        }
    }
    var cellHeight: CGFloat = 0.0
    
    @IBOutlet weak var searchField: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        configurePage()
        getMovies()
    }
    func getMovies() {
        MovieNetwork.shared.fetchMovies(model: Movie.self) { (data) in

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
        MovieNetwork.shared.fetchMovies(with: "search/movie", query: textField.text, model: Movie.self) { (movie) in
            self.populerMovies = movie.results ?? []
            self.collectionView.reloadData()
        }
    }
}
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y
        if !isHeaderHidden, scrollView.contentOffset.y > cellHeight-10 {
            self.contentViewTopConstaint.constant =  -scrollView.contentOffset.y
            configureHeader()
        }else if isHeaderHidden, scrollOffset < 10.0 {
            self.contentViewTopConstaint.constant =  0.0
            configureHeader()
        }else if scrollOffset > collectionView.contentSize.height - 100 - scrollView.frame.size.height {
            guard !MovieNetwork.shared.isPaging else {return}
            MovieNetwork.shared.setPaging(with: true)
            MovieNetwork.shared.fetchMovies(page: currentPage+1, model: Movie.self) { (movies) in
                self.currentPage += 1
                self.populerMovies.append(contentsOf: movies.results ?? [])
                MovieNetwork.shared.setPaging(with: false)
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
    func configureHeader() {
        isHeaderHidden = !isHeaderHidden
        UIView.animate(withDuration: 3.0) {
            self.view.layoutIfNeeded()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return populerMovies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Nibs.movieCollectionCell, for: indexPath) as! MovieCollectionCell
        let data = populerMovies[indexPath.row]
        cell.configure(title: data.title, posterPath: data.posterPath, imdb: data.imdbScore, movieID : data.movieID)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MovieCollectionCell
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: Constants.Routes.detailsPage) as! DetailsViewController
        detailsVC.delegate = self
        detailsVC.movieID = populerMovies[indexPath.row].movieID
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
extension ViewController: FavoriteDelegate{
    func didChangeFavorite() {
        collectionView.reloadData()
    }
}
