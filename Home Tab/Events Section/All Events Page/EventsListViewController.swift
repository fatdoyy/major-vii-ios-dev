//
//  EventsListViewController.swift
//  major-7-ios
//
//  Created by jason on 5/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import Localize_Swift
import AMScrollingNavbar
import SwiftMessages

class EventsListViewController: ScrollingNavigationViewController {
    static let storyboardID = "eventsListVC"
    
    var isFromLoginView: Bool?
    
    let searchResultsVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "buskersSearchVC") as! BuskersSearchViewController
    var searchController: UISearchController!
    
    var featuredEvents = [Event]()
    var bookmarkedEventIDArray = [String]() //IMPORTANT: Adding an array to local to control bookmarkBtn's state because of cell reuse issues
    var boolArr = [Int]()
    
    //Custom refresh control
    var refreshView: RefreshView!
    var customRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
        return refreshControl
    }()
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .m7DarkGray()
        
        isFromLoginView = false

        setupLeftBarItems()
        setupRightBarItems()
        setupMainCollectionView()
        setupRefreshView()
        getFeaturedEvents()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //transparent navigation bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = .m7DarkGray()
        navigationController?.navigationBar.isTranslucent = false
        TabBar.hide(from: self)
        
        NotificationCenter.default.setObserver(self, selector: #selector(refreshEventListVC), name: .refreshEventListVC, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(refreshFeaturedSectionCell(_:)), name: .refreshFeaturedSectionCell, object: nil)
        
        if UserService.current.isLoggedIn() && isFromLoginView == true {
            print("popped from loginView")
            
            //refresh mainCollectionView
            let allSections = mainCollectionView.visibleCells
            for section in allSections {
                if let cell = section as? TrendingSection { //Trending section
                    cell.trendingCollectionView.reloadData()
                }
                
                if let cell = section as? FollowingSection { //following section
                    cell.getCurrentUserFollowings()
                    cell.getCurrentUserFollowingsEvents()
                }
                
                if let cell = section as? BookmarkedSection { //bookmark section
                    cell.emptyLoginShadowView.alpha = 0
                    cell.getBookmarkedEvents()
                    cell.bookmarksCollectionView.alpha = 1
                }
            }
            
            mainCollectionView.reloadData()
            isFromLoginView = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //hide navigation bar
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(mainCollectionView, delay: 20.0)
        }
        
        if UserService.current.isLoggedIn() {
            let bookmarkedSection = mainCollectionView.visibleCells //hide bookmark section when view did disappear
            for cell in bookmarkedSection {
                if let cell = cell as? BookmarkedSection {
                    if cell.bookmarksCollectionView.alpha == 0 {
                        cell.bookmarksCollectionView.alpha = 1
                        cell.reloadIndicator.alpha = 0
                    }
                }
            }
        }
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.stopFollowingScrollView(showingNavbar: false)
        }
        
        if self.isMovingFromParent {
            NotificationCenter.default.post(name: .removeTrendingSectionObservers, object: nil)
            NotificationCenter.default.post(name: .removeFollowingSectionObservers, object: nil)
            NotificationCenter.default.post(name: .removeBookmarkedSectionObservers, object: nil)
            NotificationCenter.default.removeObserver(self)

            tabBarController?.tabBar.isHidden = false
        }
        TabBar.show(from: self)
    }
    
    @objc private func refreshEventListVC() {
        isFromLoginView = true
    }
    
    func showLoginVC() {
        let loginVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        self.present(loginVC, animated: true, completion: nil)
    }
}

//MARK: - API Calls | Featured Cell delegate | Bookmark btn action
extension EventsListViewController: FeaturedCellDelegate {
    private func getFeaturedEvents() { //get trending events list
        mainCollectionView.isUserInteractionEnabled = false
        EventService.getTrendingEvents().done { response in
            self.featuredEvents = response.list.shuffled()
            for _ in 0 ..< self.featuredEvents.count {
                self.boolArr.append(Int.random(in: 0 ... 1))
            }
            }.ensure {
                self.mainCollectionView.isUserInteractionEnabled = true
                self.mainCollectionView.reloadData()

                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    func checkBookmarkBtnState(cell: FeaturedCell, indexPath: IndexPath) {
        if UserService.current.isLoggedIn() {
            if let eventID = featuredEvents[indexPath.row].id {
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
        if UserService.current.isLoggedIn() {
            if let eventID = self.featuredEvents[tappedIndex.row].id {
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
                            
                            NotificationCenter.default.post(name: .refreshTrendingSectionCell, object: nil, userInfo: ["add_id": eventID]) //refresh bookmarkBtn state in TrendingSection
                            NotificationCenter.default.post(name: .refreshFollowingSectionCell, object: nil, userInfo: ["add_id": eventID]) //refresh bookmarkBtn state in FollowingSection
                            NotificationCenter.default.post(name: .refreshBookmarkedSection, object: nil, userInfo: ["add_id": eventID]) //reload collection view in BookmarkedSection

                            
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
                            NotificationCenter.default.post(name: .refreshTrendingSectionCell, object: nil, userInfo: ["remove_id": eventID]) //refresh bookmarkBtn state in TrendingSection
                            NotificationCenter.default.post(name: .refreshFollowingSectionCell, object: nil, userInfo: ["remove_id": eventID]) //refresh bookmarkBtn state in FollowingSection
                            NotificationCenter.default.post(name: .refreshBookmarkedSection, object: nil, userInfo: ["remove_id": eventID]) //reload collection view in BookmarkedSection
                            
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
    
    @objc private func refreshFeaturedSectionCell(_ notification: Notification) {
        let visibleCells = mainCollectionView.visibleCells
        var featuredCells = [FeaturedCell]() //setup array to get FeaturedCell only because mainCollectionView contains different type of cells (e.g. TrendingSection)
        
        for cell in visibleCells {
            if let cell = cell as? FeaturedCell {
                featuredCells.append(cell)
            }
        }
        
        if let event = notification.userInfo {
            if let addID = event["add_id"] as? String {
                bookmarkedEventIDArray.remove(object: addID) //add id from local array

                for cell in featuredCells { //loop featuredCells only
                    if cell.eventID == addID { //add bookmark
                        addBookmarkAnimation(cell: cell)
                    }
                }

            } else if let removeID = event["remove_id"] as? String {  //Callback from Bookmarked Section , check after removing bookmark
                bookmarkedEventIDArray.remove(object: removeID) //remove id from local array

                for cell in featuredCells {
                    if cell.eventID == removeID { //remove bookmark
                        removeBookmarkAnimation(cell: cell)
                    }
                }

            } else if let checkID = event["check_id"] as? String { //Callback from Event Details, check after dismissing event details VC
                UserService.getBookmarkedEvents().done { response in
                    if !response.list.isEmpty {
                        if response.list.contains(where: { $0.targetEvent?.id == checkID }) { //check visible cell is bookmarked or not
                            for cell in featuredCells { //check bookmarked list contains id
                                if cell.eventID == checkID && (cell.bookmarkBtn.backgroundColor?.isEqual(UIColor.clear))! { //add bookmark
                                    if !self.bookmarkedEventIDArray.contains(checkID) {
                                        self.bookmarkedEventIDArray.append(checkID)
                                        print("Callback from details array \(self.bookmarkedEventIDArray)")
                                    }
                                    self.addBookmarkAnimation(cell: cell)
                                }
                            }

                        } else { //checkID is not in bookmarked list
                            if self.bookmarkedEventIDArray.contains(checkID) {
                                self.bookmarkedEventIDArray.remove(object: checkID)
                            }

                            for cell in featuredCells {
                                if cell.eventID == checkID && (cell.bookmarkBtn.backgroundColor?.isEqual(UIColor.mintGreen()))! {
                                    self.removeBookmarkAnimation(cell: cell)
                                }
                            }
                        }

                    } else { //bookmarked list is empty, remove id from array
                        if self.bookmarkedEventIDArray.contains(checkID) {
                            self.bookmarkedEventIDArray.remove(object: checkID)
                        }

                        for cell in featuredCells {
                            self.removeBookmarkAnimation(cell: cell)
                        }
                    }
                    }.ensure { UIApplication.shared.isNetworkActivityIndicatorVisible = false }.catch { error in }

            }
        }
    }
}

//MARK: - UI related
extension EventsListViewController {
    private func setupMainCollectionView() {
        
        mainCollectionView.backgroundColor = .m7DarkGray()
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.showsHorizontalScrollIndicator = false
        mainCollectionView.refreshControl = customRefreshControl
        
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
        mainCollectionView.register(UINib.init(nibName: "TrendingSection", bundle: nil), forCellWithReuseIdentifier: TrendingSection.reuseIdentifier)
        mainCollectionView.register(UINib.init(nibName: "FollowingSection", bundle: nil), forCellWithReuseIdentifier: FollowingSection.reuseIdentifier)
        mainCollectionView.register(UINib.init(nibName: "BookmarkedSection", bundle: nil), forCellWithReuseIdentifier: BookmarkedSection.reuseIdentifier)
        mainCollectionView.register(UINib.init(nibName: "FeaturedSectionHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FeaturedSectionHeader.reuseIdentifier)
        mainCollectionView.register(UINib.init(nibName: "FeaturedCell", bundle: nil), forCellWithReuseIdentifier: FeaturedCell.reuseIdentifier)
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
        titleLabel.text = "Events"
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
    
    private func setupRightBarItems() {
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 32, height: 32)
        menuBtn.setImage(UIImage(named: "search"), for: .normal)
        menuBtn.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 32)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItem
    }
    
    @objc private func searchTapped() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: EventSearchViewController.storyboardID)
        
        self.navigationController?.hero.navigationAnimationType = .autoReverse(presenting: .cover(direction: .down))
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    private func addBookmarkAnimation(cell: FeaturedCell) {
        cell.bookmarkBtn.isUserInteractionEnabled = false
        
        cell.bookmarkBtnIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) {
            cell.bookmarkBtnIndicator.alpha = 1
        }
        
        UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
            cell.bookmarkBtn.setImage(nil, for: .normal)
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            UIView.animate(withDuration: 0.2) {
                cell.bookmarkBtn.backgroundColor = .mintGreen()
                cell.bookmarkBtnIndicator.alpha = 0
            }
            UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
            }, completion: nil)
            cell.bookmarkBtn.isUserInteractionEnabled = true
        }
    }
    
    private func removeBookmarkAnimation(cell: FeaturedCell) {
        cell.bookmarkBtn.isUserInteractionEnabled = false
        
        cell.bookmarkBtnIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) {
            cell.bookmarkBtnIndicator.alpha = 1
        }
        
        UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
            cell.bookmarkBtn.setImage(nil, for: .normal)
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            UIView.animate(withDuration: 0.2) {
                cell.bookmarkBtn.backgroundColor = .clear
                cell.bookmarkBtnIndicator.alpha = 0
            }
            UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
            }, completion: nil)
            cell.bookmarkBtn.isUserInteractionEnabled = true
        }
    }
}

//MARK: - Custom refresh control
extension EventsListViewController {
    func setupRefreshView() {
        if let objOfRefreshView = Bundle.main.loadNibNamed("RefreshView", owner: self, options: nil)?.first as? RefreshView {
            NotificationCenter.default.setObserver(self, selector: #selector(endRefreshing), name: .eventListEndRefreshing, object: nil)

            // Initializing the 'refreshView'
            refreshView = objOfRefreshView
            // Giving the frame as per 'tableViewRefreshControl'
            refreshView.frame = customRefreshControl.frame
            // Adding the 'refreshView' to 'tableViewRefreshControl'
            refreshView.setupUI()
            customRefreshControl.addSubview(refreshView)
        }
    }
    
    @objc func refreshCollectionView() {
        mainCollectionView.isUserInteractionEnabled = false
        refreshView.startAnimation()
        print("refreshing")
        
        //First refresh upcoming events section
        NotificationCenter.default.post(name: .refreshTrendingSection, object: nil)
        NotificationCenter.default.post(name: .refreshFollowingSection, object: nil)
        NotificationCenter.default.post(name: .refreshBookmarkedSection, object: nil)
        
        //refresh featured ...TODO
        bookmarkedEventIDArray.removeAll()
        featuredEvents.removeAll()
        //mainCollectionView.reloadItems(inSection: 3) //3 is Featured section
        mainCollectionView.reloadData()
        
        getFeaturedEvents()
    }
    
    @objc func endRefreshing() {
        mainCollectionView.isUserInteractionEnabled = true
        customRefreshControl.endRefreshing()
    }
}

//MARK: - UICollectionView delegate
extension EventsListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let section = EventsListSection(rawValue: section) {
            switch section {
            case .Featured: return featuredEvents.count
            default:        return 1 //return the cell contains horizontal collection view
            }
        } else {
            fatalError("numberOfItemsInSection section error!")
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let section = EventsListSection(rawValue: indexPath.section) {
            switch section {
            case .Following:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: FollowingSection.reuseIdentifier, for: indexPath) as! FollowingSection
                if UserService.current.isLoggedIn() {
                    cell.delegate = self
                } else {
                    //hide following section if not logged in (i.e. disable constriants)
                    for constraint in cell.layoutConstraints {
                        constraint.isActive = false
                    }
                }
                return cell
                
            case .Bookmarked:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: BookmarkedSection.reuseIdentifier, for: indexPath) as! BookmarkedSection
                cell.delegate = self
                if !UserService.current.isLoggedIn() {
                    cell.bookmarksCountLabel.text = "No account? It's totally free to create one!"
                }
                return cell
                
            case .Featured:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: FeaturedCell.reuseIdentifier, for: indexPath) as! FeaturedCell
                if !featuredEvents.isEmpty {
                    for view in cell.skeletonViews { //hide all skeleton views
                        view.hideSkeleton()
                    }
                    
                    if let id = featuredEvents[indexPath.row].id {
                        cell.eventID = id
                    }
                    
                    cell.delegate = self
                    cell.myIndexPath = indexPath
                    cell.eventTitle.text = featuredEvents[indexPath.row].title
                    cell.performerLabel.text = featuredEvents[indexPath.row].organizerProfile?.name
                    cell.bookmarkCountLabel.text = "201"
                    
                    if let imgUrl = URL(string: (featuredEvents[indexPath.row].images.first?.secureUrl)!) {
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
                        cell.verifiedIcon.alpha = self.featuredEvents[indexPath.row].organizerProfile?.verified ?? true ? 1 : 0
                    }
                    
                    checkBookmarkBtnState(cell: cell, indexPath: indexPath)
                }
                return cell
                
            default: //case 0, trending section
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: TrendingSection.reuseIdentifier, for: indexPath) as! TrendingSection
                cell.delegate = self
                return cell
            }
        } else {
            fatalError("cellForItemAt section error!")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let section = EventsListSection(rawValue: indexPath.section) {
            let width = self.view.frame.width
            switch section {
            case .Following:
                let size = UserService.current.isLoggedIn() ? CGSize(width: width, height: FollowingSection.height) : CGSize(width: width, height: 1)
                return size
                
            case .Bookmarked:   return CGSize(width: width, height: BookmarkedSection.height)
            case .Featured:     return CGSize(width: FeaturedCell.width, height: FeaturedCell.height)
            default:            return CGSize(width: width, height: TrendingSection.height) //case 0, trending section
            }
        } else {
            fatalError("sizeForItemAt section error!")
        }
    }
    
    //Header view for featured section
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind{
        case UICollectionView.elementKindSectionHeader:
            if indexPath.section == EventsListSection.Featured.rawValue {
                let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FeaturedSectionHeader.reuseIdentifier, for: indexPath) as! FeaturedSectionHeader
                return reusableView
            } else {
                let reusableView = UICollectionReusableView(frame: .zero)
                return reusableView
            }
        default:
            fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == EventsListSection.Featured.rawValue {
            return CGSize(width: mainCollectionView.bounds.width, height: FeaturedSectionHeader.height)
        } else {
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == EventsListSection.Featured.rawValue {
            return 15
        } else {
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == EventsListSection.Featured.rawValue {
            print("\(indexPath.row)")
            EventDetailsViewController.push(from: self, eventID: "")
        }
    }
    
}

//MARK: - Trending Section Delegate
extension EventsListViewController: TrendingSectionDelegate {
    func trendingCellTapped(eventID: String) {
        EventDetailsViewController.push(from: self, eventID: eventID)
    }
}

//MARK: - Following Section Delegate
extension EventsListViewController: FollowingSectionDelegate {
    func followingCellTapped(eventID: String) {
        EventDetailsViewController.push(from: self, eventID: eventID)
    }
}

//MARK: - Bookmark Section Delegate
extension EventsListViewController: BookmarkSectionDelegate {
    func bookmarkedCellTapped(eventID: String) {
        EventDetailsViewController.push(from: self, eventID: eventID, isFromBookmarkedSection: true)
    }
}

enum EventsListSection: Int {
    case Trending = 0, Following, Bookmarked, Featured
}
