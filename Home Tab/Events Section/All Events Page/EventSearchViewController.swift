//
//  EventSearchViewController.swift
//  major-7-ios
//
//  Created by jason on 21/8/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import SwiftMessages
import NVActivityIndicatorView

class EventSearchViewController: UIViewController {
    static let storyboardID = "eventsSearchVC"

    let keywords = ["canto-pop", "j-pop", "blues", "alternative rock", "punk", "country", "house", "edm", "electronic", "dance", "k-pop", "acid jazz", "downtempo"]
    
    var trendingEvents = [Event]()
    var bookmarkedEventIDArray = [String]() //IMPORTANT: Adding an array to local to control bookmarkBtn's state because of cell reuse issues
    var boolArr = [Int]()
    
    var searchTask: DispatchWorkItem? //avoid live search throttle
    var searchResults = [Event]()
    var isSearching = false

    let searchController = UISearchController(searchResultsController: nil)
    
    var keywordsCollectionView: UICollectionView!
    var mainCollectionView: UICollectionView!
    var emptySearchResultsLabel: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .m7DarkGray()
        setupUI()
        getTrendingEvents()
    }
    
}

//MARK: - API Calls | Featured Cell delegate | Bookmark btn action
extension EventSearchViewController: FeaturedCellDelegate {
    private func getTrendingEvents() { //get trending events list
        mainCollectionView.isUserInteractionEnabled = false
        EventService.getTrendingEvents().done { response in
            self.trendingEvents = response.list.shuffled()
            for _ in 0 ..< self.trendingEvents.count {
                self.boolArr.append(Int.random(in: 0 ... 1))
            }
            }.ensure {
                self.mainCollectionView.isUserInteractionEnabled = true
                self.mainCollectionView.reloadData()
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    private func searchWith(query: String) {
        emptySearchResultsLabel.text = "Searching for \"\(query)\""
        searchResults.removeAll()
        bookmarkedEventIDArray.removeAll()
        mainCollectionView.reloadData()
        
        SearchService.byEvents(query: query).done { response in
            if !response.list.isEmpty {
                self.searchResults = response.list
                //self.searchResults.append(contentsOf: response.list)
                for _ in 0 ..< self.searchResults.count {
                    self.boolArr.append(Int.random(in: 0 ... 1))
                }
                if self.mainCollectionView.alpha == 0 {
                    UIView.animate(withDuration: 0.2) {
                        self.mainCollectionView.alpha = 1
                        self.emptySearchResultsLabel.alpha = 0
                    }
                }
            } else {
                self.emptySearchResultsLabel.shake()
                HapticFeedback.createNotificationFeedback(style: .error)
                self.emptySearchResultsLabel.text = "No results for \"\(self.searchController.searchBar.text ?? "")\""
                UIView.animate(withDuration: 0.2) {
                    self.mainCollectionView.alpha = 0
                    self.emptySearchResultsLabel.alpha = 1
                }

                HapticFeedback.createNotificationFeedback(style: .error)
            }
            }.ensure {
                self.mainCollectionView.reloadData()
                self.isSearching = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }

    }
    
    func checkBookmarkBtnState(cell: FeaturedCell, indexPath: IndexPath) {
        if UserService.User.isLoggedIn() {
            if let eventID = trendingEvents[indexPath.row].id {
                if !bookmarkedEventIDArray.contains(eventID) {
                    /// Check if local array is holding this bookmarked cell
                    /// NOTE: This check is to prevent cell reuse issues, all bookmarked events will be saved in server
                    
                    UserService.getBookmarkedEvents().done { response in
                        if !response.list.isEmpty {
                            for event in response.list {
                                //check if bookmarked list contains id
                                let isBookmarked = event.targetEvent?.id == eventID
                                if isBookmarked {
                                    self.bookmarkedEventIDArray.append(eventID) //add this cell to local array to avoid reuse
                                    
                                    //animate button state
                                    UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                        cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                                    }, completion: nil)
                                    
                                    UIView.animate(withDuration: 0.2) {
                                        cell.bookmarkBtnIndicator.alpha = 0
                                        cell.bookmarkBtn.backgroundColor = .mintGreen()
                                    }
                                    
                                } else { //not bookmarked
                                    //animate button state to default
                                    UIView.animate(withDuration: 0.2) {
                                        cell.bookmarkBtnIndicator.alpha = 0
                                    }
                                    
                                    UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                        cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                                    }, completion: nil)
                                }
                            }
                        } else { //logged in user have no bookmarked events
                            //animate button state to default
                            UIView.animate(withDuration: 0.2) {
                                cell.bookmarkBtnIndicator.alpha = 0
                            }
                            
                            UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                            }, completion: nil)
                        }
                        }.ensure {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }.catch { error in }
                    
                } else { //this cell is bookmarked and held by local array, will bypass check from api
                    //animate button state
                    UIView.animate(withDuration: 0.2) {
                        cell.bookmarkBtn.backgroundColor = .mintGreen()
                        cell.bookmarkBtnIndicator.alpha = 0
                    }
                    
                    UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                    }, completion: nil)
                }
            }
        }
    }
    
    func searchResultCheckBookmarkBtnState(cell: FeaturedCell, indexPath: IndexPath) {
        if UserService.User.isLoggedIn() {
            if let eventID = searchResults[indexPath.row].id {
                if !bookmarkedEventIDArray.contains(eventID) {
                    /// Check if local array is holding this bookmarked cell
                    /// NOTE: This check is to prevent cell reuse issues, all bookmarked events will be saved in server
                    
                    UserService.getBookmarkedEvents().done { response in
                        if !response.list.isEmpty {
                            for event in response.list {
                                //check if bookmarked list contains id
                                let isBookmarked = event.targetEvent?.id == eventID
                                if isBookmarked {
                                    self.bookmarkedEventIDArray.append(eventID) //add this cell to local array to avoid reuse
                                    
                                    //animate button state
                                    UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                        cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                                    }, completion: nil)
                                    
                                    UIView.animate(withDuration: 0.2) {
                                        cell.bookmarkBtnIndicator.alpha = 0
                                        cell.bookmarkBtn.backgroundColor = .mintGreen()
                                    }
                                    
                                } else { //not bookmarked
                                    //animate button state to default
                                    UIView.animate(withDuration: 0.2) {
                                        cell.bookmarkBtnIndicator.alpha = 0
                                    }
                                    
                                    UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                        cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                                    }, completion: nil)
                                }
                            }
                        } else { //logged in user have no bookmarked events
                            //animate button state to default
                            UIView.animate(withDuration: 0.2) {
                                cell.bookmarkBtnIndicator.alpha = 0
                            }
                            
                            UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                            }, completion: nil)
                        }
                        }.ensure {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }.catch { error in }
                    
                } else { //this cell is bookmarked and held by local array, will bypass check from api
                    //animate button state
                    UIView.animate(withDuration: 0.2) {
                        cell.bookmarkBtn.backgroundColor = .mintGreen()
                        cell.bookmarkBtnIndicator.alpha = 0
                    }
                    
                    UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                    }, completion: nil)
                }
            }
        }
    }

    func bookmarkBtnTapped(cell: FeaturedCell, tappedIndex: IndexPath) {
        if UserService.User.isLoggedIn() {
            if let eventID = isSearching ? self.searchResults[tappedIndex.row].id : self.trendingEvents[tappedIndex.row].id {
                if (cell.bookmarkBtn.backgroundColor?.isEqual(UIColor.clear))! { //do bookmark action
                    HapticFeedback.createImpact(style: .light)
                    cell.bookmarkBtn.isUserInteractionEnabled = false
                    
                    //animate button state
                    UIView.animate(withDuration: 0.2) {
                        cell.bookmarkBtnIndicator.alpha = 1
                    }
                    
                    UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        cell.bookmarkBtn.setImage(nil, for: .normal)
                    }, completion: nil)
                    
                    //create bookmark action
                    EventService.createBookmark(eventID: eventID).done { _ in
                        }.ensure {
                            UIView.animate(withDuration: 0.2) {
                                cell.bookmarkBtn.backgroundColor = .mintGreen()
                                cell.bookmarkBtnIndicator.alpha = 0
                            }
                            
                            UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                            }, completion: nil)
                            
                            cell.bookmarkBtn.isUserInteractionEnabled = true
                            if !self.bookmarkedEventIDArray.contains(eventID) {
                                self.bookmarkedEventIDArray.append(eventID)
                            }
                            
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            HapticFeedback.createNotificationFeedback(style: .success)
                        }.catch { error in }
                    
                } else { //remove bookmark
                    HapticFeedback.createImpact(style: .light)
                    cell.bookmarkBtn.isUserInteractionEnabled = false
                    
                    //animate button state
                    cell.bookmarkBtnIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2) {
                        cell.bookmarkBtnIndicator.alpha = 1
                    }
                    
                    UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        cell.bookmarkBtn.setImage(nil, for: .normal)
                    }, completion: nil)
                    
                    //remove bookmark action
                    EventService.removeBookmark(eventID: eventID).done { response in
                        UIView.animate(withDuration: 0.2) {
                            cell.bookmarkBtn.backgroundColor = .clear
                            cell.bookmarkBtnIndicator.alpha = 0
                        }
                        
                        UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                        }, completion: nil)
                        
                        cell.bookmarkBtn.isUserInteractionEnabled = true
                        
                        if let index = self.bookmarkedEventIDArray.firstIndex(of: eventID) {
                            self.bookmarkedEventIDArray.remove(at: index)
                        }
                        }.ensure {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            HapticFeedback.createNotificationFeedback(style: .success)
                        }.catch { error in }
                }
                
            } else {
                print("Can't get event id")
            }
            
        } else { // not logged in
            SwiftMessages.show(view: InAppNotifications.loginWarning())
        }
        
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
        setupEmptySearchResultsLabel()
    }
    
    private func setupKeywordsCollectionView() {
        let layout = HashtagsFlowLayout()
        layout.scrollDirection = .horizontal
        
        keywordsCollectionView = UICollectionView(frame: CGRect(origin: .zero, size: .zero), collectionViewLayout: layout)
        keywordsCollectionView.backgroundColor = .m7DarkGray()
        keywordsCollectionView.dataSource = self
        keywordsCollectionView.delegate = self
        
        keywordsCollectionView.showsVerticalScrollIndicator = false
        keywordsCollectionView.showsHorizontalScrollIndicator = false
        keywordsCollectionView.register(UINib.init(nibName: "SearchViewKeywordCell", bundle: nil), forCellWithReuseIdentifier: SearchViewKeywordCell.reuseIdentifier)
        
        view.addSubview(keywordsCollectionView)
        keywordsCollectionView.snp.makeConstraints { (make) in
            make.height.equalTo(24)
            make.width.equalTo(UIScreen.main.bounds.width)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        let overlayLeft = UIImageView(image: UIImage(named: "collectionview_overlay_left_to_right"))
        view.addSubview(overlayLeft)
        overlayLeft.snp.makeConstraints { (make) in
            make.height.equalTo(24)
            make.width.equalTo(20)
            make.top.left.equalTo(keywordsCollectionView)
        }
        
        let overlayRight = UIImageView(image: UIImage(named: "collectionview_overlay_right_to_left"))
        view.addSubview(overlayRight)
        overlayRight.snp.makeConstraints { (make) in
            make.height.equalTo(24)
            make.width.equalTo(20)
            make.top.right.equalTo(keywordsCollectionView)
        }
    }
    
    private func setupMainCollectionView() {
        let layout = UICollectionViewFlowLayout()
        
        mainCollectionView = UICollectionView(frame: CGRect(origin: .zero, size: .zero), collectionViewLayout: layout)
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        mainCollectionView.backgroundColor = .m7DarkGray()
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        mainCollectionView.register(UINib.init(nibName: "FeaturedCell", bundle: nil), forCellWithReuseIdentifier: FeaturedCell.reuseIdentifier)
        view.addSubview(mainCollectionView)
        mainCollectionView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(keywordsCollectionView.snp.bottom).offset(10)
            make.left.right.bottom.equalTo(0)
        }
        
        let overlayTop = UIImageView(image: UIImage(named: "collectionview_overlay_top_to_bottom"))
        view.addSubview(overlayTop)
        overlayTop.snp.makeConstraints { (make) in
            make.height.equalTo(10)
            make.width.equalTo(UIScreen.main.bounds.width)
            make.top.equalTo(mainCollectionView.snp.top)
        }
    }
    
    private func setupEmptySearchResultsLabel() {
        emptySearchResultsLabel = UILabel()
        emptySearchResultsLabel.alpha = 0
        emptySearchResultsLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        emptySearchResultsLabel.textColor = .white
        view.addSubview(emptySearchResultsLabel)
        emptySearchResultsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(keywordsCollectionView).offset(55)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        //navigationController?.navigationBar.barTintColor = .darkGray()
        
        navigationController?.navigationBar.backgroundColor = .clear
    }
    
    private func setupLeftBarItems() {
        let customView = UIView(frame: CGRect(x: 15, y: 10, width: UIScreen.main.bounds.width, height: 30))
        customView.backgroundColor = .clear
        
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        backBtn.setImage(UIImage(named: "icon_close"), for: .normal)
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
            if !string.isEmpty {
                //Cancel previous task if any
                self.searchTask?.cancel()
                
                //Replace previous task with a new one
                let newTask = DispatchWorkItem { [weak self] in
                    self?.searchWith(query: string)
                }
                self.searchTask = newTask
                
                //Execute task in 0.3 seconds (if not cancelled !)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: newTask)
            }
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
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        isSearching = true
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        print("Ended search?")
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchResults.removeAll()
        bookmarkedEventIDArray.removeAll()
        mainCollectionView.reloadData()
        
        if mainCollectionView.alpha != 1 {
            UIView.animate(withDuration: 0.2) {
                self.mainCollectionView.alpha = 1
                self.emptySearchResultsLabel.alpha = 0
            }
        }
    }
}

//MARK: - UISearchResultsUpdating Delegate
extension EventSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
    }
}

//MARK: - UICollectionView delegate
extension EventSearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case keywordsCollectionView:
            return keywords.count
            
        case mainCollectionView:
            if isSearching {
                return searchResults.isEmpty ? 10 : searchResults.count
            } else {
                return trendingEvents.isEmpty ? 10 : trendingEvents.count
            }
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case keywordsCollectionView:
            let cell = keywordsCollectionView.dequeueReusableCell(withReuseIdentifier: SearchViewKeywordCell.reuseIdentifier, for: indexPath) as! SearchViewKeywordCell
            cell.keyword.text = keywords[indexPath.row]
            return cell

        case mainCollectionView:
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: FeaturedCell.reuseIdentifier, for: indexPath) as! FeaturedCell
           
            if isSearching {
                if !searchResults.isEmpty {
                    for view in cell.skeletonViews { //hide all skeleton views
                        view.hideSkeleton()
                    }
                    
                    cell.delegate = self
                    cell.myIndexPath = indexPath
                    cell.eventTitle.text = searchResults[indexPath.row].title
                    cell.performerLabel.text = searchResults[indexPath.row].organizerProfile?.name
                    cell.bookmarkCountLabel.text = "201"
                    
                    if let imgUrl = URL(string: (searchResults[indexPath.row].images.first?.secureUrl)!) {
                        cell.bgImgView.kf.setImage(with: imgUrl, options: [.transition(.fade(0.2))])
                    }
                    
                    for view in cell.viewsToShowLater {
                        UIView.animate(withDuration: 0.2) {
                            view.alpha = 1
                        }
                    }
                    
                    UIView.animate(withDuration: 0.4) {
                        cell.premiumBadge.alpha = self.boolArr[indexPath.row] == 1 ? 1 : 0
                    }
                    UIView.animate(withDuration: 0.4) {
                        cell.verifiedIcon.alpha = self.searchResults[indexPath.row].organizerProfile?.verified ?? true ? 1 : 0
                    }
                    
                    searchResultCheckBookmarkBtnState(cell: cell, indexPath: indexPath)
                }
            } else {
                if !trendingEvents.isEmpty {
                    for view in cell.skeletonViews { //hide all skeleton views
                        view.hideSkeleton()
                    }
                    
                    cell.delegate = self
                    cell.myIndexPath = indexPath
                    cell.eventTitle.text = trendingEvents[indexPath.row].title
                    cell.performerLabel.text = trendingEvents[indexPath.row].organizerProfile?.name
                    cell.bookmarkCountLabel.text = "201"
                    
                    if let imgUrl = URL(string: (trendingEvents[indexPath.row].images.first?.secureUrl)!) {
                        cell.bgImgView.kf.setImage(with: imgUrl, options: [.transition(.fade(0.2))])
                    }
                    
                    for view in cell.viewsToShowLater {
                        UIView.animate(withDuration: 0.2) {
                            view.alpha = 1
                        }
                    }
                    
                    UIView.animate(withDuration: 0.4) {
                        cell.premiumBadge.alpha = self.boolArr[indexPath.row] == 1 ? 1 : 0
                    }
                    UIView.animate(withDuration: 0.4) {
                        cell.verifiedIcon.alpha = self.trendingEvents[indexPath.row].organizerProfile?.verified ?? true ? 1 : 0
                    }
                    
                    checkBookmarkBtnState(cell: cell, indexPath: indexPath)
                }
            }
            
            return cell
            
        default: return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case keywordsCollectionView:
            let keyword = keywords[indexPath.row]
            let size = (keyword as NSString).size(withAttributes: nil)
            return CGSize(width: size.width + 32, height: SearchViewKeywordCell.height)
            
        case mainCollectionView:
            return CGSize(width: FeaturedCell.width, height: FeaturedCell.height)
            
        default:
            return CGSize(width: FollowingSectionCell.width, height: FollowingSectionCell.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case keywordsCollectionView:
            print("tapped") //TODO
            
        case mainCollectionView:
            isSearching ? EventDetailsViewController.push(from: self, eventID: searchResults[indexPath.row].id ?? "") : EventDetailsViewController.push(from: self, eventID: trendingEvents[indexPath.row].id ?? "")

        default: print("error")

        }
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
