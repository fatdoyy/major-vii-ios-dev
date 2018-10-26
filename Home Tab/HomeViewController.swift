//
//  HomeViewController.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let headerViewId = "header"
    private let eventsSectionId = "eventsSection"
    private let newsHeaderViewId = "newsHeader"
    
    private let newsCellType1Id = "newsCell1"
    private let newsCellType2Id = "newsCell2"
    private let newsCellType3Id = "newsCell3"
    private let newsCellType4Id = "newsCell4"
    private let newsCellType5Id = "newsCell5"

    let cellType = 5
    
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
        
        mainCollectionView.register(UINib.init(nibName: "NewsCellType1", bundle: nil), forCellWithReuseIdentifier: newsCellType1Id)
        mainCollectionView.register(UINib.init(nibName: "NewsCellType2", bundle: nil), forCellWithReuseIdentifier: newsCellType2Id)
        mainCollectionView.register(UINib.init(nibName: "NewsCellType3", bundle: nil), forCellWithReuseIdentifier: newsCellType3Id)
        mainCollectionView.register(UINib.init(nibName: "NewsCellType4", bundle: nil), forCellWithReuseIdentifier: newsCellType4Id)
        mainCollectionView.register(UINib.init(nibName: "NewsCellType5", bundle: nil), forCellWithReuseIdentifier: newsCellType5Id)

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: UICollectionView Data Source

extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 20
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 { //events section
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: eventsSectionId, for: indexPath) as! EventsSection
            return cell
        } else { //news section
            switch cellType {
            case 1:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: newsCellType1Id, for: indexPath) as! NewsCellType1
                let bgImg = UIImage(named: "music-studio-12")
                
                cell.timeLabel.text = "2 months ago"
                cell.bgImgView.image = bgImg
                
                return cell
            case 2:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: newsCellType2Id, for: indexPath) as! NewsCellType2
                let bgImg = UIImage(named: "music-studio-12")
                
                cell.newsTitle.text = "This is the title. This is the title. This is the title. This is the title. This is the title. This is the title. "
                cell.bgImgView.image = bgImg
                
                return cell
            case 3:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: newsCellType3Id, for: indexPath) as! NewsCellType3
                let bgImg = UIImage(named: "music-studio-12")
                
                cell.newsTitle.text = "This is the title. This is the title. This is the title. This is the title."
                cell.subTitle.text = "Unforgettable experience."
                cell.bgImgView.image = bgImg
                
                return cell
            case 4:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: newsCellType4Id, for: indexPath) as! NewsCellType4
                //let bgImg = UIImage(named: "music-studio-12")
                
                cell.newsTitle.text = "This is the title. This is the title. This is the title. This is the title."
                cell.subTitle.text = "Shakin' the ground"
                //cell.bgImgView.image = bgImg
                
                return cell
            case 5:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: newsCellType5Id, for: indexPath) as! NewsCellType5
                //let bgImg = UIImage(named: "music-studio-12")
                
                cell.newsTitle.text = "This is the title. This is the title. This is the title. This is the title."
                cell.subTitle.text = "Shakin' the ground"
                //cell.bgImgView.image = bgImg
                
                return cell
            default:
                fatalError("Unexpected cell type!")
            }
            

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        if indexPath.section == 0 {
            // Upcoming events section
            return CGSize(width: width, height: EventsSection.sectionHeight)
        } else {
            // News section
            switch cellType {
            case 1, 2:
                return CGSize(width: NewsCellType1.cellWidth, height: NewsCellType1.cellHeight)
            default:
                return CGSize(width: NewsCellType3.cellWidth, height: NewsCellType3.cellHeight)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1{
            print("\(indexPath.row)")
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
