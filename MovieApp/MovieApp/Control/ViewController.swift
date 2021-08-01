//
//  ViewController.swift
//  MovieApp
//
//  Created by obss on 30.07.2021.
//

import UIKit

class ViewController: UIViewController{

    var populerMovies : [Result] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchField: UISearchBar!
    
    override func viewDidAppear(_ animated: Bool) {
        searchField.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Movies", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: Constants.ColorPalette.mediumColor)!])
        searchField.searchTextField.textColor = UIColor(named: Constants.ColorPalette.titleColor)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       configurePage()
        MovieNetwork.shared.fetchMovies { (data) in
            
            if let movies = data.results {
                self.populerMovies = movies
                self.collectionView.reloadData()
            }
        }
    }
    func configurePage(){
        navigationController?.navigationBar.isHidden = true
        searchField.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        collectionView.backgroundColor = UIColor(patternImage: UIImage())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: Constants.Nibs.movieCollectionCell, bundle: nil), forCellWithReuseIdentifier: Constants.Nibs.movieCollectionCell)
        collectionView.setCollectionViewLayout(UICollectionViewFlowLayout(), animated: true)
    }
}
extension ViewController : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return populerMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Nibs.movieCollectionCell, for: indexPath) as! MovieCollectionCell
        let data = populerMovies[indexPath.row]
        cell.configure(title: data.title, posterPath: data.posterPath)
        return cell
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
