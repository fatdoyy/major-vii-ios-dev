//
//  EventDetailsView.swift
//  major-7-ios
//
//  Created by jason on 26/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import Localize_Swift
import SkeletonView

class EventDetailsView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var performerLabel: UILabel!
    
    @IBOutlet weak var hashtagsCollectionView: UICollectionView!
    
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var venueTitleLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    
    @IBOutlet weak var descTitleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var imgCollectionView: UICollectionView!
    
    @IBOutlet weak var remarksTitleLabel: UILabel!
    @IBOutlet weak var remarksLabel: UILabel!
    
    @IBOutlet weak var webTitleLabel: UILabel!
    @IBOutlet weak var webLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("EventDetailsView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        
        contentView.backgroundColor = .darkGray
        contentView.layer.cornerRadius = GlobalCornerRadius.value + 4
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        hashtagsCollectionView.backgroundColor = .red
        
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
                imgCollectionView.removeFromSuperview()
            case 1334:
                print("iPhone 6/6S/7/8")
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                print("iPhone X, Xs")
            case 2688:
                print("iPhone Xs Max")
            case 1792:
                print("iPhone Xr")
            default:
                print("unknown")
            }
        }
        
    }
}
