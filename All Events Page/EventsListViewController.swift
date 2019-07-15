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

class EventsListViewController: ScrollingNavigationViewController {
    
    static let storyboardId = "eventsVC"
    
    var isFromLoginView: Bool?
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .m7DarkGray()
        
        isFromLoginView = false
        
        mainCollectionView.backgroundColor = .m7DarkGray()
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.showsHorizontalScrollIndicator = false
        
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
        setupLeftBarItems()
        setupRightBarItems()
        
        mainCollectionView.register(UINib.init(nibName: "TrendingSection", bundle: nil), forCellWithReuseIdentifier: TrendingSection.reuseIdentifier)
        mainCollectionView.register(UINib.init(nibName: "FollowingSection", bundle: nil), forCellWithReuseIdentifier: FollowingSection.reuseIdentifier)
        mainCollectionView.register(UINib.init(nibName: "BookmarkedSection", bundle: nil), forCellWithReuseIdentifier: BookmarkedSection.reuseIdentifier)
        
        mainCollectionView.register(UINib.init(nibName: "FeaturedSectionHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FeaturedSectionHeader.reuseIdentifier)
        
        mainCollectionView.register(UINib.init(nibName: "FeaturedCell", bundle: nil), forCellWithReuseIdentifier: FeaturedCell.reuseIdentifier)
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
        
        if UserService.User.isLoggedIn() && isFromLoginView == true {
            print("popped from loginView")
            
            //refresh mainCollectionView
            let allSections = mainCollectionView.visibleCells
            for section in allSections {
                if let cell = section as? TrendingSection { //bookmark section
                    cell.trendingCollectionView.reloadData()
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

        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.stopFollowingScrollView(showingNavbar: false)
        }
        
        if self.isMovingFromParent {
            NotificationCenter.default.post(name: .removeTrendingSectionObservers, object: nil)
            NotificationCenter.default.post(name: .removeBookmarkedSectionObservers, object: nil)
            NotificationCenter.default.removeObserver(self)

            tabBarController?.tabBar.isHidden = false
        }

        TabBar.show(from: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if !self.isMovingFromParent {
            let bookmarkedSection = mainCollectionView.visibleCells //hide bookmark section when view did disappear
            for cell in bookmarkedSection {
                if let cell = cell as? BookmarkedSection {
                    cell.bookmarksCollectionView.alpha = 0
                    cell.reloadIndicator.alpha = 1
                }
            }
        }
        
    }
    
    @objc private func refreshEventListVC() {
        print("CALLED")
        isFromLoginView = true
    }
    
    private func setupLeftBarItems() {
        let customView = UIView(frame: CGRect(x: 15, y: 10, width: 110, height: 30.0))
        customView.backgroundColor = .clear
        
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        backBtn.setImage(UIImage(named: "back"), for: .normal)
        backBtn.addTarget(self, action: #selector(popView), for: .touchUpInside)
        customView.addSubview(backBtn)
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: backBtn.frame.maxX + 20, y: -7, width: 90, height: 44)
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .whiteText()
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.text = "Events"
        customView.addSubview(titleLabel)
        
        let menuBarItem = UIBarButtonItem(customView: customView)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 110)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 30)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
    
    private func setupRightBarItems() {
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 32, height: 32)
        menuBtn.setImage(UIImage(named:"search"), for: .normal)
        menuBtn.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 32)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItem
    }
    
    @objc private func searchTapped() {
        print("tapped")
    }
    
    @objc private func popView() {
        //navigationController?.hero.navigationAnimationType = .uncover(direction: .down)
        navigationController?.popViewController(animated: true)
    }

    func showLoginVC() {
        let loginVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        
        loginVC.hero.isEnabled = true

        self.navigationItem.title = ""
        self.navigationController?.hero.navigationAnimationType = .autoReverse(presenting: .cover(direction: .up))
        self.navigationController?.pushViewController(loginVC, animated: true)
        
        //self.present(loginVC, animated: true, completion: nil)
    }
}

extension EventsListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let section = EventsListSection(rawValue: section) {
            switch section {
            case .Featured:  return 7 //featuredEvents.count
            default: return 1 //return the cell contains horizontal collection view
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
                cell.delegate = self
                return cell
                
            case .Bookmark:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: BookmarkedSection.reuseIdentifier, for: indexPath) as! BookmarkedSection
                cell.delegate = self
                let count = cell.bookmarkedEvents.count
                let isCountEqualsToOne = count == 1
                
                UIView.animate(withDuration: 0.2) {
                    cell.bookmarksCountLabel.alpha = 1
                }
                
                if UserService.User.isLoggedIn() {
                    cell.bookmarksCountLabel.text =  isCountEqualsToOne ? "1 Event" : "\(count) Events"
                } else {
                    cell.bookmarksCountLabel.text = "No account? It's totally free to create one!"
                }
                
                return cell
                
            case .Featured:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: FeaturedCell.reuseIdentifier, for: indexPath) as! FeaturedCell
                cell.delegate = self
                cell.eventTitle.text = "Music on the Habour"
                cell.performerLabel.text = "Music ABC"
                cell.bookmarkCountLabel.text = "201"
                cell.bgImgView.image = UIImage(named: "cat")
                return cell
                
            default: //case 0, trending section
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: TrendingSection.reuseIdentifier, for: indexPath) as! TrendingSection
                cell.delegate = self
                cell.getTrendingEvents()
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
            case .Following:    return CGSize(width: width, height: FollowingSection.height)
            case .Bookmark:     return CGSize(width: width, height: BookmarkedSection.height)
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
            EventDetailsViewController.push(from: self, eventId: "")
        }
    }
    
}

//MARK: Trending Section Delegate
extension EventsListViewController: TrendingSectionDelegate{
    func trendingCellTapped(eventId: String) {
        EventDetailsViewController.push(from: self, eventId: eventId)
    }

}

//MARK: Following Section Delegate
extension EventsListViewController: FollowingSectionDelegate{
    func followingCellTapped() {
        EventDetailsViewController.push(from: self, eventId: "")
    }
}

//MARK: Bookmark Section Delegate
extension EventsListViewController: BookmarkSectionDelegate{
    func bookmarkedCellTapped(eventId: String) {
        EventDetailsViewController.push(from: self, eventId: eventId)
    }
}

//MARK: Featured Section bookmark btn
extension EventsListViewController: FeaturedCellDelegate{
    func bookmarkBtnTapped() {
        
    }
}

enum EventsListSection: Int {
    case Trending = 0, Following, Bookmark, Featured
}
