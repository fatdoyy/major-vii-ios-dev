//
//  BookmarkedEventCollectionHeaderView.swift
//  major-7-ios
//
//  Created by jason on 28/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class BookmarkedEventCollectionHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "bookmarkedEventCollectionHeaderView"
    static let height: CGFloat = 84
    
    @IBOutlet weak var bookmarkedEventsLabel: UILabel!
    @IBOutlet weak var eventCount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        bookmarkedEventsLabel.textColor = .white
        bookmarkedEventsLabel.text = "Bookmarked Events"
        
        eventCount.textColor = .purpleText()
    }
    
}
