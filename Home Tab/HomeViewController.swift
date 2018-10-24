//
//  HomeViewController.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    private let eventsSectionId = "eventsSection"
    private let newsHeaderViewId = "newsHeader"
    private let newsCellId = "newsCell"
    private let headerViewId = "header"
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray()
        
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        
        mainCollectionView.backgroundColor = .darkGray()
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.showsHorizontalScrollIndicator = false
        
        mainCollectionView.register(UINib.init(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerViewId)
        mainCollectionView.register(UINib.init(nibName: "EventsSection", bundle: nil), forCellWithReuseIdentifier: eventsSectionId)
        mainCollectionView.register(UINib.init(nibName: "NewsHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: newsHeaderViewId)
        mainCollectionView.register(UINib.init(nibName: "NewsCell", bundle: nil), forCellWithReuseIdentifier: newsCellId)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: UICollection View Delegate Methods

extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 10
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: eventsSectionId, for: indexPath) as! EventsSection
            return cell
        } else {
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: newsCellId, for: indexPath) as! NewsCell
            let bgImg = UIImage(named: "music-studio-12")
            
            cell.timeLabel.text = "2 months ago"
            cell.bgImgView.frame = CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: NewsCell.cellHeight)
            cell.bgImgView.image = bgImg
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        
        if indexPath.section == 0 {
            // Upcoming events section
            return CGSize(width: width, height: EventsSection.sectionHeight)
        } else {
            // News section
            return CGSize(width: NewsCell.cellWidth, height: NewsCell.cellHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: mainCollectionView.bounds.width, height: HeaderView.viewHeight)
        } else {
            return CGSize(width: mainCollectionView.bounds.width, height: NewsHeaderView.viewHeight)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let section = indexPath.section
            switch section {
            case 1:
                let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: newsHeaderViewId, for: indexPath) as! NewsHeaderView
                return reusableview
            default: //case 0
                let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerViewId, for: indexPath) as! HeaderView
                
                reusableview.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: HeaderView.viewHeight)
                return reusableview
            }
    
        default:  fatalError("Unexpected element kind")
        }
    }
}
