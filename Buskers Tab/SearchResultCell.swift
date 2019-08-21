//
//  SearchResultCell.swift
//  major-7-ios
//
//  Created by jason on 25/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class SearchResultCell: UICollectionViewCell {
    
    private typealias `Self` = SearchResultCell
    
    static let reuseIdentifier = "searchResultCell"
    static let width: CGFloat = UIScreen.main.bounds.width - 40
    static let aspectRatio: CGFloat = width / 200
    static let height: CGFloat = width / aspectRatio
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var gradientBg: UIView!
    
    @IBOutlet weak var verifiedBg: UIView!
    @IBOutlet weak var verifiedIcon: UIImageView!
    
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var followerIcon: UIImageView!
    
    @IBOutlet weak var premiumBadge: UIImageView!

    @IBOutlet weak var performerLabel: UILabel!
    @IBOutlet weak var genre: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.layer.cornerRadius = GlobalCornerRadius.value
        
        gradientBg.layer.cornerRadius = GlobalCornerRadius.value
        gradientBg.layer.insertSublayer(GradientLayer.create(frame: CGRect(x: 0, y: 0, width: Self.width, height: Self.height), colors: [.random, .random], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5), cornerRadius: true), at: 0)
        gradientBg.backgroundColor = .clear
        gradientBg.alpha = 0.45
        
        bgImgView.layer.cornerRadius = GlobalCornerRadius.value
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.clipsToBounds = true
        
        verifiedBg.alpha = 0
        verifiedBg.layer.cornerRadius = 14
        
        premiumBadge.alpha = 0
    }

    override func prepareForReuse() {
        verifiedBg.alpha = 0
        premiumBadge.alpha = 0
        bgImgView.image = nil
    }
}
