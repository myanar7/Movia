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
    var isSearched = false
    var currentPage = 1
    let activityView = UIActivityIndicatorView(style: .large)
    @IBOutlet weak var contentViewTopConstaint: NSLayoutConstraint!
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    var cellHeight: CGFloat = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePage()
        getMovies()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let fadeView:UIView = UIView()
        fadeView.frame = self.view.frame
        fadeView.backgroundColor = UIColor.white
        fadeView.alpha = 0.4
        
        self.view.addSubview(fadeView)
        
        self.view.addSubview(activityView)
        activityView.hidesWhenStopped = true
        activityView.center = self.view.center
        activityView.startAnimating()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            self.getMovies()
        }
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1, delay: 1, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.collectionView?.reloadData()
                self.collectionView?.alpha = 1
                fadeView.removeFromSuperview()
                self.activityView.stopAnimating()
            }, completion: nil)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    func getMovies() {
        MovieNetwork.shared.fetchMovies(model: Movie.self) { (data) in

            if let movies = data.results {
                self.populerMovies = movies
                self.currentPage = 1
                self.collectionView.reloadData()
            }
        }
    }
    func configurePage() {
        cellHeight = collectionView.frame.height/3
        searchField.searchTextField.delegate = self
        searchField.delegate = self
        navigationController?.navigationBar.isHidden = true
        collectionView.backgroundColor = UIColor(patternImage: UIImage())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: Constants.Nibs.movieCollectionCell, bundle: nil), forCellWithReuseIdentifier: Constants.Nibs.movieCollectionCell)
        collectionView.setCollectionViewLayout(UICollectionViewFlowLayout(), animated: true)
    }
}
// MARK: - Search Field Delegate
extension ViewController: UISearchTextFieldDelegate, UISearchBarDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            getMovies()
            isSearched = false
        } else {
            currentPage = 1
            isSearched = true
            MovieNetwork.shared.fetchMovies(with: Constants.Network.searchingParameter, query: textField.text, model: Movie.self) { (movie) in
                self.populerMovies = movie.results ?? []
                self.collectionView.reloadData()
            }
        }
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        getMovies()
        isSearched = false
    }
}
// MARK: - Collection View Protocols
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y
        if !isHeaderHidden, scrollView.contentOffset.y > cellHeight-20 {
            self.contentViewTopConstaint.constant =  -collectionView.frame.height/2.3
            configureHeader()
        } else if isHeaderHidden, scrollOffset < 10.0 {
            self.contentViewTopConstaint.constant =  0.0
            configureHeader()
        } else if scrollOffset > collectionView.contentSize.height + 300 - scrollView.frame.size.height {
            guard !MovieNetwork.shared.isPaging else {return}
            MovieNetwork.shared.setPaging(with: true)
            MovieNetwork.shared.fetchMovies(with: (isSearched) ? Constants.Network.searchingParameter : nil, page: currentPage+1, query: searchField.text, model: Movie.self) { (movies) in
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
        DispatchQueue.main.async {
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
        cell.configure(title: data.title, posterPath: data.posterPath, imdb: data.imdbScore, movieID: data.movieID)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: Constants.Routes.detailsPage) as! DetailsViewController
        detailsVC.delegate = self
        detailsVC.movieID = populerMovies[indexPath.row].movieID
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width*0.46, height: 300.0)
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
extension ViewController: FavoriteDelegate {
    func didChangeFavorite() {
        collectionView.reloadData()
    }
}
