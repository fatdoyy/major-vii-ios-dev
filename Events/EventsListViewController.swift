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

class EventsListViewController: ScrollingNavigationViewController, UIGestureRecognizerDelegate {
    
    static let storyboardId = "eventsVc"
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        mainCollectionView.backgroundColor = .darkGray()
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.showsHorizontalScrollIndicator = false
        
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
        setupLeftBarItems()
        setupRightBarItems()
        
        mainCollectionView.register(UINib.init(nibName: "TrendingSection", bundle: nil), forCellWithReuseIdentifier: TrendingSection.reuseIdentifier)
        mainCollectionView.register(UINib.init(nibName: "FollowingSection", bundle: nil), forCellWithReuseIdentifier: FollowingSection.reuseIdentifier)
        mainCollectionView.register(UINib.init(nibName: "BookmarkSection", bundle: nil), forCellWithReuseIdentifier: BookmarkSection.reuseIdentifier)
        
        mainCollectionView.register(UINib.init(nibName: "FeaturedSectionHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: FeaturedSectionHeader.reuseIdentifier)
        
        mainCollectionView.register(UINib.init(nibName: "FeaturedCell", bundle: nil), forCellWithReuseIdentifier: FeaturedCell.reuseIdentifier)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //transparent navigation bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = .darkGray()
        navigationController?.navigationBar.isTranslucent = false
        TabBar.hide(rootView: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //hide navigation bar
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(mainCollectionView, delay: 10.0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TabBar.show(rootView: self)
    }
    
    private func setupLeftBarItems(){
        let customView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 110, height: 44.0))
        customView.backgroundColor = .clear
        
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 5, y: 10, width: 14.13, height: 24)
        menuBtn.setImage(UIImage(named:"back"), for: .normal)
        menuBtn.addTarget(self, action: #selector(popView), for: .touchUpInside)
        customView.addSubview(menuBtn)
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: menuBtn.frame.maxX + 20, y: 0, width: 90, height: 44)
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .whiteText()
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.text = "Events"
        customView.addSubview(titleLabel)
        
        let menuBarItem = UIBarButtonItem(customView: customView)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 110)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
    
    private func setupRightBarItems(){
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
    
    @objc private func searchTapped(){
        print("tapped")
    }
    
    @objc private func popView(){
        navigationController?.hero.navigationAnimationType = .uncover(direction: .down)
        navigationController?.popViewController(animated: true)
    }
    
    //swipe pop gesture
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension EventsListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let section = Section(rawValue: section){
            switch section{
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
        if let section = Section(rawValue: indexPath.section){
            switch section{
            case .Following:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: FollowingSection.reuseIdentifier, for: indexPath) as! FollowingSection
                cell.delegate = self
                return cell
            case .Bookmark:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: BookmarkSection.reuseIdentifier, for: indexPath) as! BookmarkSection
                cell.delegate = self
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
                return cell
            }
        } else {
            fatalError("cellForItemAt section error!")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let section = Section(rawValue: indexPath.section){
            let width = self.view.frame.width
            switch section{
            case .Following:    return CGSize(width: width, height: FollowingSection.height)
            case .Bookmark:     return CGSize(width: width, height: BookmarkSection.height)
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
            if indexPath.section == Section.Featured.rawValue{
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
        if section == Section.Featured.rawValue{
            return CGSize(width: mainCollectionView.bounds.width, height: FeaturedSectionHeader.height)
        } else {
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == Section.Featured.rawValue{
            return 15
        } else {
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == Section.Featured.rawValue{
            print("\(indexPath.row)")
            EventDetailsViewController.push(fromView: self, eventId: "")
        }
    }
    
}

//MARK: Trending Section Delegate
extension EventsListViewController: TrendingSectionDelegate{
    func trendingCellTapped() {
        EventDetailsViewController.push(fromView: self, eventId: "")
    }
}

//MARK: Following Section Delegate
extension EventsListViewController: FollowingSectionDelegate{
    func followingCellTapped() {
        EventDetailsViewController.push(fromView: self, eventId: "")
    }
}

//MARK: Bookmark Section Delegate
extension EventsListViewController: BookmarkSectionDelegate{
    func bookmarkCellTapped() {
        EventDetailsViewController.push(fromView: self, eventId: "")
    }
}

//MARK: Featured Section bookmark btn
extension EventsListViewController: FeaturedCellDelegate{
    func bookmarkBtnTapped() {
        
    }
}

enum Section: Int {
    case Trending = 0, Following, Bookmark, Featured
}
