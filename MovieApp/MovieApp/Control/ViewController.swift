//
//  ViewController.swift
//  MovieApp
//
//  Created by obss on 30.07.2021.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    var populerMovies: [Result] = []
    var isHeaderHidden = false
    var isSearched = false
    var currentPage = 1
    @IBOutlet weak var contentViewTopConstaint: NSLayoutConstraint!
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var cellHeight: CGFloat = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingScreen()
        configurePage()
        getMovies()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    func loadingScreen () {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicatorView.insertSubview(blurEffectView, at: 0)
        activityIndicator.startAnimating()
    }
    func getMovies() {
        MovieNetwork.shared.fetchMovies(model: Movie.self) { (data, error) in
            if let safeData = data, let movies = safeData.results, safeData.success == nil {
                self.populerMovies = movies
                self.currentPage = 1
                self.collectionView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.activityIndicator.stopAnimating()
                    self.indicatorView.isHidden = true
                }
            } else {
                self.didCrashed(error: error)
            }
        }
    }
    func configurePage() {
        cellHeight = collectionView.frame.height/3
        if #available(iOS 13.0, *) {
            searchField.searchTextField.delegate = self
            } else {
              if let textField = searchField.value(forKey: "searchField") as? UITextField {
                textField.delegate = self
              }
            }
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
            MovieNetwork.shared.fetchMovies(with: Constants.Network.searchingParameter, query: textField.text, model: Movie.self) { (data, error) in
                if let safeData = data, let movies = safeData.results, safeData.success == nil{
                    self.populerMovies = movies
                    self.collectionView.reloadData()
                } else {
                    self.didCrashed(error: error)
                }
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
        } else if scrollOffset > collectionView.contentSize.height + 100 - scrollView.frame.size.height {
            guard !MovieNetwork.shared.isPaging else {return}
            MovieNetwork.shared.setPaging(with: true)
            MovieNetwork.shared.fetchMovies(with: (isSearched) ? Constants.Network.searchingParameter : nil, page: currentPage+1, query: searchField.text, model: Movie.self) { (data, error) in
                if let safeData = data, let movies = safeData.results, safeData.success == nil {
                    self.currentPage += 1
                    self.populerMovies.append(contentsOf: movies)
                    self.collectionView.reloadData()
                    MovieNetwork.shared.setPaging(with: false)
                } else {
                    self.didCrashed(error: error)
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //
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
        let detailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.Routes.detailsPage) as! DetailsViewController
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
extension UIViewController {
    func didCrashed (error: AFError?) {
        let alertMessage = (error != nil) ? error?.errorDescription : "Uygulama Düzgün Çalışmıyor"
        let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let navigationStack = self.navigationController?.viewControllers, navigationStack.count > 1 {
                self.navigationController?.navigationBar.isHidden = true
                self.navigationController?.popViewController(animated: true)
            } else {
                self.loadView()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
