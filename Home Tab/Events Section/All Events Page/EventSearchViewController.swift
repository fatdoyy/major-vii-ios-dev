//
//  EventSearchViewController.swift
//  major-7-ios
//
//  Created by jason on 21/8/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class EventSearchViewController: UIViewController {
    static let storyboardID = "eventsSearchVC"

    let searchController = UISearchController(searchResultsController: nil)
    
    var keywordsCollectionView: UICollectionView!
    var mainCollectionView: UICollectionView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .m7DarkGray()
        setupUI()
    }
    
}

//MARK: - UI related
extension EventSearchViewController {
    private func setupUI() {
        setupNavBar()
        setupLeftBarItems()
        setupSearchController()
        setupKeywordsCollectionView()
        setupMainCollectionView()
    }
    
    private func setupKeywordsCollectionView() {
        keywordsCollectionView = UICollectionView(frame: CGRect(origin: .zero, size: .zero), collectionViewLayout: HashtagsFlowLayout())
        keywordsCollectionView.backgroundColor = .pumpkin
        view.addSubview(keywordsCollectionView)
        keywordsCollectionView.snp.makeConstraints { (make) in
            make.height.equalTo(24)
            make.width.equalTo(UIScreen.main.bounds.width)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
    
    private func setupMainCollectionView() {
        
    }
    
    private func setupLeftBarItems() {
        let customView = UIView(frame: CGRect(x: 15, y: 10, width: UIScreen.main.bounds.width, height: 30))
        customView.backgroundColor = .clear
        
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        backBtn.setImage(UIImage(named: "back"), for: .normal)
        backBtn.addTarget(self, action: #selector(popView), for: .touchUpInside)
        customView.addSubview(backBtn)
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: backBtn.frame.maxX + 20, y: -7, width: UIScreen.main.bounds.width - 30, height: 44)
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .whiteText()
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.text = "Search for events"
        customView.addSubview(titleLabel)
        
        let menuBarItem = UIBarButtonItem(customView: customView)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 32 - 40)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 30)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }

    @objc private func popView() {
        //navigationController?.hero.navigationAnimationType = .uncover(direction: .down)
        navigationController?.popViewController(animated: true)
    }

}

//MARK: - UINavigation Bar setup
extension EventSearchViewController {
    private func setupNavBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        //navigationController?.navigationBar.barTintColor = .darkGray()
        
        navigationController?.navigationBar.backgroundColor = .m7DarkGray()
    }
}

//MARK: - Search Controller setup
extension EventSearchViewController {
    private func setupSearchController() {
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.isTranslucent = true
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.backgroundColor = UIColor.m7DarkGray().withAlphaComponent(0.8)
        definesPresentationContext = true
        searchController.searchResultsController?.view.addObserver(self, forKeyPath: "hidden", options: [], context: nil)
        setupKeyboardToolbar()
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [.foregroundColor: UIColor.white]
        
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            //setup UI
            if let backgroundview = textfield.subviews.first {
                // Rounded corner
                backgroundview.layer.cornerRadius = GlobalCornerRadius.value / 1.2
                backgroundview.clipsToBounds = true
            }
            
            //add target to detect input and search in real time
            textfield.addTarget(self, action: #selector(searchWithQuery), for: .editingChanged)
        }
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupKeyboardToolbar() {
        let toolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        toolbar.barStyle = .black
        
        let dismissBtn = UIButton(type: .custom)
        dismissBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        dismissBtn.setImage(UIImage(named: "icon_dismiss_keyboard"), for: .normal)
        dismissBtn.addTarget(self, action: #selector(doneWithNumberPad), for: .touchUpInside)
        
        let item = UIBarButtonItem(customView: dismissBtn)
        toolbar.items = [item]
        searchController.searchBar.inputAccessoryView = toolbar
    }
    
    @objc func doneWithNumberPad() {
        searchController.searchBar.endEditing(true)
    }
    
    //Do search action whenever user types
    @objc func searchWithQuery() {
        if let string = searchController.searchBar.text {
            print(string)
            //delegate?.searchWith(query: string)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let someView: UIView = object as! UIView? {
            if (someView == self.searchController.searchResultsController?.view && (keyPath == "hidden") && (searchController.searchResultsController?.view.isHidden)! && searchController.searchBar.isFirstResponder) {
                searchController.searchResultsController?.view.isHidden = false
            }
        }
    }
    
}

//MARK: - UISearchControllerDelegate Delegate
extension EventSearchViewController: UISearchControllerDelegate, UISearchBarDelegate {
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
            //searchController.searchResultsController?.view.isHidden = false
            //NotificationCenter.default.post(name: .showSCViews, object: nil)
        } else {
            //NotificationCenter.default.post(name: .hideSCViews, object: nil)
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

//MARK: - UISearchResultsUpdating Delegate
extension EventSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
    }
}


//MARK: - function to push this view controller
extension EventSearchViewController {
    static func push(from view: UIViewController, eventID: String) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: EventSearchViewController.storyboardID) as! EventSearchViewController
        
        view.navigationItem.title = ""
        view.navigationController?.hero.navigationAnimationType = .autoReverse(presenting: .zoom)
        view.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    static func present(from view: UIViewController, eventID: String) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailsVC = storyboard.instantiateViewController(withIdentifier: EventSearchViewController.storyboardID) as! EventSearchViewController
        
        detailsVC.hero.isEnabled = true
        detailsVC.hero.modalAnimationType = .autoReverse(presenting: .zoom)
        view.present(detailsVC, animated: true, completion: nil)
    }
}
