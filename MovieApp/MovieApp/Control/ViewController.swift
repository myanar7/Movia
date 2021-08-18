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
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var cellHeight: CGFloat = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingScreen()
        configurePage()
        getMovies()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        collectionView.reloadData()
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func loadingScreen () {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = indicatorView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicatorView.insertSubview(blurEffectView, at: 0)
        activityIndicator.startAnimating()
    }
    @objc func getMovies() {
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
        if #available(iOS 13.0, *) {
            searchField.searchTextField.delegate = self
            if let clearButton = searchField.searchTextField.value(forKey: "_clearButton")as? UIButton {
                clearButton.addTarget(self, action: #selector(self.getMovies), for: .touchUpInside)
                }
            } else {
              if let textField = searchField.value(forKey: "searchField") as? UITextField, let clearButton = textField.value(forKey: "_clearButton")as? UIButton {
                textField.delegate = self
                clearButton.addTarget(self, action: #selector(self.getMovies), for: .touchUpInside)
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
                if let safeData = data, let movies = safeData.results, safeData.success == nil {
                    self.populerMovies = movies
                    self.collectionView.reloadData()
                } else {
                    self.didCrashed(error: error)
                }
            }
        }
    }
}
// MARK: - Collection View Protocols
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y
        if !isHeaderHidden, scrollView.contentOffset.y > 300.0 {    // When contentOffset pass away a cell height
            self.contentViewTopConstaint.constant =  -headerView.frame.height
            configureHeader()
        } else if isHeaderHidden, scrollOffset < 10.0 { // When contentOffset on the top of collectionView
            self.contentViewTopConstaint.constant =  0.0
            configureHeader()
        } else if scrollOffset > collectionView.contentSize.height + 100 - scrollView.frame.size.height {
            guard !MovieNetwork.shared.isPaging else {return}// When contentOffset pass away height of the whole collectionView
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
            UIView.animate(withDuration: 0.8) {
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
        cell.configure(posterPath: data.posterPath, imdb: data.imdbScore, movieID: data.movieID)
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
        return CGSize(width: 150, height: 250)
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
