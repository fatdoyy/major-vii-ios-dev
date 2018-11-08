//
//  EventsListViewController.swift
//  major-7-ios
//
//  Created by jason on 5/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import Localize_Swift

class EventsListViewController: UIViewController, UIGestureRecognizerDelegate {
    
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
        hideTabBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showTabBar()
    }
    
    private func setupLeftBarItems(){
        let customView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 110, height: 44.0))
        customView.backgroundColor = .darkGray()
        
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 5, y: 10, width: 14.13, height: 24)
        menuBtn.setImage(UIImage(named:"back"), for: .normal)
        menuBtn.addTarget(self, action: #selector(popView), for: .touchUpInside)
        customView.addSubview(menuBtn)
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: menuBtn.frame.maxX + 20, y: 0, width: 90, height: 44)
        titleLabel.backgroundColor = .darkGray()
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
        navigationController?.popViewController(animated: true)
    }
    
    private func hideTabBar(){
        var frame = self.tabBarController?.tabBar.frame
        if frame?.minY != self.view.frame.maxY {
            let newY = UIScreen.main.bounds.height + (frame?.size.height)!
            frame?.origin.y = newY
            UIView.animate(withDuration: 0.5, animations: {
                self.tabBarController?.tabBar.frame = frame!
            })
        }
    }
    
    private func showTabBar(){
        var frame = self.tabBarController?.tabBar.frame
        let newY = UIScreen.main.bounds.height - (frame?.size.height)!
        let originY = (frame?.minY)! - (frame?.height)!
        if frame?.minY != self.view.frame.maxY {
            
            frame?.origin.y = newY
            UIView.animate(withDuration: 0.5, animations: {
                self.tabBarController?.tabBar.frame = frame!
            })
            
        } else{
            frame?.origin.y = originY
            // print(frame?.origin.y)
            print("frame resetted")
        }
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
            case .Featured:  return 4 //featuredEvents.count
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
                return cell
            case .Bookmark:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: BookmarkSection.reuseIdentifier, for: indexPath) as! BookmarkSection
                return cell
            case .Featured:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: FeaturedCell.reuseIdentifier, for: indexPath) as! FeaturedCell
                cell.eventTitle.text = "Music on the Habour"
                cell.performerLabel.text = "Music ABC"
                cell.bookmarkCountLabel.text = "201"
                cell.bgImgView.image = UIImage(named: "music-studio-12")
                return cell
            default: //case 0, trending section
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: TrendingSection.reuseIdentifier, for: indexPath) as! TrendingSection
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
        }
    }
    
}

enum Section: Int {
    case Trending = 0, Following, Bookmark, Featured
}
