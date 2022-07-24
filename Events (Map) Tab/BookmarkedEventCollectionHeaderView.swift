//
//  BookmarkedEventCollectionHeaderView.swift
//  major-7-ios
//
//  Created by jason on 28/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

protocol BookmarkedEventCollectionHeaderViewDelegate: AnyObject {
    func refreshBtnTapped()
}

class BookmarkedEventCollectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "bookmarkedEventCollectionHeaderView"
    static let height: CGFloat = 84
    weak var delegate: BookmarkedEventCollectionHeaderViewDelegate?

    @IBOutlet weak var bookmarkedEventsLabel: UILabel!
    @IBOutlet weak var eventCount: UILabel!
    @IBOutlet weak var refreshBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.setObserver(self, selector: #selector(pause), name: .pauseAnimationOnBookmarkedEventsVC, object: nil)
        bookmarkedEventsLabel.textColor = .white
        bookmarkedEventsLabel.text = "Bookmarked Events"
        
        let styleImg = UIImage(named: "icon_refresh")
        let tintedImg = styleImg!.withRenderingMode(.alwaysTemplate)
        refreshBtn.setImage(tintedImg, for: .normal)
        refreshBtn.tintColor = .white
        refreshBtn.rotate()
        
        eventCount.textColor = .purpleText()
    }

    @IBAction func refreshBtnTapped(_ sender: Any) {
        refreshBtn.layer.resumeAnimation()
        refreshBtn.isUserInteractionEnabled = false
        delegate?.refreshBtnTapped()
    }
    
    @objc func pause() {
        refreshBtn.isUserInteractionEnabled = true
        refreshBtn.layer.pauseAnimation()
    }
}
