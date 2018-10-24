//
//  EventsCollectionViewCell.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class EventsSection: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    static let sectionHeight: CGFloat = 163 //equals to xib frame height
    private let eventCellId = "eventCell"

    @IBOutlet weak var eventsCollectionView: UICollectionView!
    @IBOutlet weak var eventsLabel: UILabel!
    @IBOutlet weak var viewAllBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .darkGray()
        
        eventsLabel.text = "Upcoming Events"
        eventsLabel.textColor = .whiteText()
        
        viewAllBtn.setTitle("VIEW ALL", for: .normal)
        viewAllBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
        
        eventsCollectionView.dataSource = self
        eventsCollectionView.delegate = self
        
        eventsCollectionView.showsVerticalScrollIndicator = false
        eventsCollectionView.showsHorizontalScrollIndicator = false
        
        eventsCollectionView.backgroundColor = .darkGray()
        eventsCollectionView.register(UINib.init(nibName: "EventsCell", bundle: nil), forCellWithReuseIdentifier: eventCellId)

    }
    
    // MARK: UICollectionView Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = eventsCollectionView.dequeueReusableCell(withReuseIdentifier: eventCellId, for: indexPath) as! EventsCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: EventsCell.cellWidth, height: EventsCell.cellHeight)
    }
    
}
