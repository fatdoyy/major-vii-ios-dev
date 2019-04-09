//
//  BuskersViewController.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class BuskersViewController: UIViewController {
    //gesture for swipe-pop
    var gesture: UIGestureRecognizer?
    
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    var screenHeight: CGFloat = UIScreen.main.bounds.height
    var mainCollectionView: UICollectionView!

    let searchResultsVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "buskersSearchVC") as! BuskersSearchViewController
    var searchController: UISearchController!
    
    let img: [UIImage] = [UIImage(named: "gif9_thumbnail")!, UIImage(named: "gif10_thumbnail")!, UIImage(named: "gif11_thumbnail")!, UIImage(named: "cat")!, UIImage(named: "gif0_thumbnail")!, UIImage(named: "gif1_thumbnail")!, UIImage(named: "gif2_thumbnail")!, UIImage(named: "gif3_thumbnail")!, UIImage(named: "gif4_thumbnail")!, UIImage(named: "gif5_thumbnail")!, UIImage(named: "gif6_thumbnail")!, UIImage(named: "gif7_thumbnail")!, UIImage(named: "gif8_thumbnail")!]
    
    let names: [String] = ["jamistry", "水曜日のカンパネラ", "Anomalie", "鄧小巧", "陳奕迅", "Mr.", "RubberBand", "Postman", "Zeplin", "SourceTree", "Xcode", "August", "VIRT"]
    let genres: [String] = ["canto-pop", "j-pop", "blues", "alternative rock", "punk", "country", "house", "edm", "electronic", "dance", "k-pop", "acid jazz", "downtempo"]
    
    var scaledImgArray = [UIImage]()
    var randomColor = [UIColor]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gesture?.delegate = self
        view.backgroundColor = .darkGray()
        hideKeyboardWhenTappedAround()
        
        for image in img {
            scaledImgArray.append(image.scaleImage(maxWidth: 220))
            randomColor.append(UIColor.random)
        }
        
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.2) {
            self.navigationController?.navigationBar.backgroundColor = .clear
            if let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView {
                statusBar.backgroundColor = .clear
            } else {
                print("Can't get status bar?")
            }
        }
    }
    

}

//MARK: UINavigation Bar setup
extension BuskersViewController {
    private func setupNavBar() {
        definesPresentationContext = true
        navigationItem.title = "Performers"
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        //navigationController?.navigationBar.barTintColor = .darkGray()
        
        UIView.animate(withDuration: 0.2) {
            self.navigationController?.navigationBar.backgroundColor = UIColor.darkGray().withAlphaComponent(0.8)

            //status bar color
            if let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView {
                statusBar.backgroundColor = UIColor.darkGray().withAlphaComponent(0.8)
            } else {
                print("Can't get status bar?")
            }
        }

    }

}

//MARK: Search Controller setup
extension BuskersViewController {
    private func setupSearchController() {
        searchResultsVC.delegate = self
        searchController = UISearchController(searchResultsController: searchResultsVC)
        searchController.delegate = self
        searchController.searchResultsUpdater = searchResultsVC
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.isTranslucent = true
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.backgroundColor = UIColor.darkGray().withAlphaComponent(0.8)
        searchController.searchResultsController?.view.addObserver(self, forKeyPath: "hidden", options: [], context: nil)
        
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            if let backgroundview = textfield.subviews.first {
                // Rounded corner
                backgroundview.layer.cornerRadius = GlobalCornerRadius.value / 1.2
                backgroundview.clipsToBounds = true
            }
        }
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let someView: UIView = object as! UIView? {
            if (someView == self.searchController.searchResultsController?.view && (keyPath == "hidden") && (searchController.searchResultsController?.view.isHidden)! && searchController.searchBar.isFirstResponder) {
                searchController.searchResultsController?.view.isHidden = false
            }
        }
    }
    
}

//MARK: UI setup
extension BuskersViewController {
    private func setupUI() {
        setupSearchController()
        
        let layout = PinterestLayout()
        layout.delegate = self
        
        mainCollectionView = UICollectionView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth, height: screenHeight)), collectionViewLayout: layout)
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        mainCollectionView.backgroundColor = .darkGray()
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        mainCollectionView.register(UINib.init(nibName: "BuskerCell", bundle: nil), forCellWithReuseIdentifier: BuskerCell.reuseIdentifier)
        view.addSubview(mainCollectionView)
        mainCollectionView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(0)
        }
    }
}

//MARK: UICollectionview delegate
extension BuskersViewController: UICollectionViewDelegate, UICollectionViewDataSource, PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scaledImgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: BuskerCell.reuseIdentifier, for: indexPath) as! BuskerCell
        cell.imgView.image = scaledImgArray[indexPath.row]
        cell.buskerName.text = names[indexPath.row]
        cell.genre.textColor = randomColor[indexPath.row]
        cell.genre.text = genres[indexPath.row]

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        BuskerProfileViewController.push(from: self, buskerName: names[indexPath.row], buskerId: "5be7f512d92f1257fd2a530e")
    }
    
    //PinterestLayout delegate
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return scaledImgArray[indexPath.row].size.height
    }
    
}

//MARK: UISearchResultsUpdating Delegate
extension BuskersViewController: UISearchControllerDelegate, UISearchBarDelegate, BuskersSearchViewControllerDelegate {
    func reassureShowingVC() {
        searchController.searchResultsController?.view.isHidden = false
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        //TabBar.hide(from: self)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        print("Tapped search bar")
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        print("Ended search?")
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.count == 0) {
            searchController.searchResultsController?.view.isHidden = false
            NotificationCenter.default.post(name: .showSCViews, object: nil)
        } else {
            NotificationCenter.default.post(name: .hideSCViews, object: nil)
        }
        
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //searchBar.text = ""
        //searchController.searchResultsController?.view.isHidden = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        NotificationCenter.default.post(name: .showSCViews, object: nil)

    }
}

//MARK: UIScrollView Delegate
extension BuskersViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //toggle tab bar
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            TabBar.toggle(from: self, hidden: true, animated: true)
        } else {
            TabBar.toggle(from: self, hidden: false, animated: true)
        }
        
        if scrollView.contentOffset.y <= 0 {
            TabBar.toggle(from: self, hidden: false, animated: true)
        }
    }
}

//MARK: Swipe pop gesture
extension BuskersViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
