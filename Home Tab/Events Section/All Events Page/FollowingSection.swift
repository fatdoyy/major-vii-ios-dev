//
//  FollowingSection.swift
//  major-7-ios
//
//  Created by jason on 7/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import BouncyLayout

protocol FollowingSectionDelegate{
    func followingCellTapped(eventID: String)
}

class FollowingSection: UICollectionViewCell {

    static let reuseIdentifier = "followingSection"
    
    var delegate: FollowingSectionDelegate?
    
    static let height: CGFloat = 238
    
    @IBOutlet weak var followingSectionTitle: UILabel!
    @IBOutlet weak var followingSectionCollectionView: UICollectionView!
    
    var followingEvents: [Event] = [] {
        didSet {
            print("Sucessfully got following events:\n\(followingEvents)")
        }
    }
    var eventsLimit = 8 //event limit per request
    var gotMoreEvents = true //lazy loading
    
    var bookmarkedEventIDArray: [String] = [] //IMPORTANT: Adding an array to local to control bookmarkBtn's state because of cell reuse issues
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        getFollowingEvents()
    }
    
}

//MARK: UI setup
extension FollowingSection {
    private func setupUI() {
        followingSectionTitle.textColor = .whiteText()
        followingSectionTitle.text = "Your Followings"
        
        if let layout = followingSectionCollectionView.collectionViewLayout as? BouncyLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 15
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        
        followingSectionCollectionView.dataSource = self
        followingSectionCollectionView.delegate = self
        
        followingSectionCollectionView.showsVerticalScrollIndicator = false
        followingSectionCollectionView.showsHorizontalScrollIndicator = false
        
        followingSectionCollectionView.backgroundColor = .m7DarkGray()
        followingSectionCollectionView.register(UINib.init(nibName: "FollowingCell", bundle: nil), forCellWithReuseIdentifier: FollowingCell.reuseIdentifier)
    }
}

//MARK: API Calls
extension FollowingSection {
    func getFollowingEvents(completion: (() -> Void)? = nil) {
        EventService.getFollowingEvents().done { response in
            self.followingEvents = response.list
            
            self.followingSectionCollectionView.reloadData()
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
}

//MARK: UICollectionView delegate
extension FollowingSection: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = UserService.User.isLoggedIn() && !followingEvents.isEmpty ? followingEvents.count : 3
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = followingSectionCollectionView.dequeueReusableCell(withReuseIdentifier: FollowingCell.reuseIdentifier, for: indexPath) as! FollowingCell
        if !followingEvents.isEmpty {
            let event = followingEvents[indexPath.row]
            
            cell.delegate = self
            cell.myIndexPath = indexPath
            cell.eventTitle.text = event.title
            cell.dateLabel.text = event.dateTime
            cell.performerLabel.text = event.organizerProfile?.name
            cell.bookmarkBtn.backgroundColor = .mintGreen()
            if let url = URL(string: event.images[0].secureUrl!) {
                cell.bgImgView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
            }
            
            for view in cell.skeletonViews { //hide all skeleton views
                view.hideSkeleton()
            }
            
            for view in cell.viewsToShowLater {
                UIView.animate(withDuration: 0.3) {
                    view.alpha = 1
                }
            }
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: FollowingCell.width, height: FollowingCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        delegate?.followingCellTapped(eventID: "")
    }
    
}

//MARK: FollowingCell delegate
extension FollowingSection: FollowingCellDelegate {
    func bookmarkBtnTapped() {
        print("tapped")
    }
}
