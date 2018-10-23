//
//  HomeViewController.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    private let sectionCellId = "event"
    private let headerViewId = "header"
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var eventsLabel: UILabel!
    @IBOutlet weak var viewAllBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.pageTitle.text = "News"
//        self.pageTitle.textColor = .whiteText()
//
//        self.eventsLabel.text = "Upcoming Events"
//        self.eventsLabel.textColor = .whiteText()
//
//        self.viewAllBtn.setTitle("VIEW ALL", for: .normal)
//        self.viewAllBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkColor()
        
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        
        mainCollectionView.backgroundColor = .darkColor()
        
        mainCollectionView.register(UINib.init(nibName: "SectionCell", bundle: nil), forCellWithReuseIdentifier: sectionCellId)
        mainCollectionView.register(UINib.init(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerViewId)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: UICollection View Delegate Methods
extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: sectionCellId, for: indexPath) as! SectionCell
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        let height : CGFloat
        
        if indexPath.section == 0 {
            // Upcoming events section
            height = 150
            return CGSize(width: width, height: height)
        } else {
            // News section
            height = 250
            return CGSize(width: width, height: height)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: mainCollectionView.bounds.width, height: 59)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerViewId, for: indexPath) as! HeaderView
            
            reusableview.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 59)
            //do other header related calls or settups
            return reusableview

        default:  fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}
