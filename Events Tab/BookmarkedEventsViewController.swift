//
//  BookmarkedEventsViewController.swift
//  major-7-ios
//
//  Created by jason on 27/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import BouncyLayout
import Kingfisher

class BookmarkedEventsViewController: UIViewController {
    
    var eventsCollectionView: UICollectionView!
    
    var randomImgUrl: [URL] = []
    var bookmarkedEvents: [BookmarkedEvent] = [] {
        didSet {
            for item in bookmarkedEvents {
                if let event = item.targetEvent {
                    if let url = event.images.randomElement()?.secureUrl {
                        randomImgUrl.append(URL(string: url)!)
                    }
                }
            }
            
            eventsCollectionView.isUserInteractionEnabled = true
            eventsCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}


//MARK: UI Setup
extension BookmarkedEventsViewController {
    private func setupUI() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: BookmarkedEventCell.width, height: BookmarkedEventCell.height)
        
        eventsCollectionView = UICollectionView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)), collectionViewLayout: layout)
        eventsCollectionView.alpha = 0
        eventsCollectionView.isUserInteractionEnabled = false
        eventsCollectionView.showsVerticalScrollIndicator = false
        eventsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 20, right: 10)
        eventsCollectionView.backgroundColor = .darkGray()
        eventsCollectionView.dataSource = self
        eventsCollectionView.delegate = self
        eventsCollectionView.register(UINib.init(nibName: "BookmarkedEventCollectionHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BookmarkedEventCollectionHeaderView.reuseIdentifier)
        eventsCollectionView.register(UINib.init(nibName: "BookmarkedEventCollectionFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: BookmarkedEventCollectionFooterView.reuseIdentifier)
        eventsCollectionView.register(UINib.init(nibName: "BookmarkedEventCell", bundle: nil), forCellWithReuseIdentifier: BookmarkedEventCell.reuseIdentifier)
        view.addSubview(eventsCollectionView)
        eventsCollectionView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(0)
        }
    }
}

//MARK: Collection
extension BookmarkedEventsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //Header/Footer View
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: BookmarkedEventCollectionHeaderView.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: BookmarkedEventCollectionFooterView.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let section = indexPath.section
            if section == 0 {
                let reusableView = eventsCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BookmarkedEventCollectionHeaderView.reuseIdentifier, for: indexPath) as! BookmarkedEventCollectionHeaderView
                reusableView.eventCount.text = bookmarkedEvents.count == 1 ? "1 Event" : "\(bookmarkedEvents.count) Events"
                
                return reusableView
            } else {
                return UICollectionReusableView()
            }
            
        case UICollectionView.elementKindSectionFooter:
            let section = indexPath.section
            if section == 0 {
                let reusableView = eventsCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: BookmarkedEventCollectionFooterView.reuseIdentifier, for: indexPath) as! BookmarkedEventCollectionFooterView
                
                return reusableView
            } else {
                return UICollectionReusableView()
            }
            
        default:  fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = bookmarkedEvents.isEmpty ? 3 : bookmarkedEvents.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = eventsCollectionView.dequeueReusableCell(withReuseIdentifier: BookmarkedEventCell.reuseIdentifier, for: indexPath) as! BookmarkedEventCell
        
        if !bookmarkedEvents.isEmpty {
            if let event = bookmarkedEvents[indexPath.row].targetEvent {
                
                
                cell.bgImgView.kf.setImage(with: randomImgUrl[indexPath.row], options: [.transition(.fade(0.4))])
//                DispatchQueue.main.async {
//                    cell.bgImgView.kf.setImage(with: self.randomImgUrl[indexPath.row], options: [.transition(.fade(0.4)), .processor(tonalFilter())])
//                }
                cell.eventTitle.text = event.title
                cell.performerName.text = event.organizerProfile?.name
                cell.bookmarkCount.text = "468" //bookmark.count
                
                for view in cell.viewsToShowLater {
                    UIView.animate(withDuration: 0.3) {
                        view.alpha = 1
                        cell.loadingIndicator.alpha = 0
                    }
                }
            }
        }
        
        return cell
    }
    
    
}
