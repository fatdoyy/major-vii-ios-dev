//
//  BookmarkedEventCell.swift
//  major-7-ios
//
//  Created by jason on 28/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class BookmarkedEventCell: UICollectionViewCell {
    
    static let reuseIdentifier = "bookmarkedEventCell"
    
    private typealias `Self` = BookmarkedEventCell
    
    static let width: CGFloat = UIScreen.main.bounds.width - 40
    static let aspectRatio: CGFloat = width / 188
    static let height: CGFloat = width / aspectRatio
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var gradientBg: UIView!
    @IBOutlet weak var bookmarkCount: UILabel!
    @IBOutlet weak var bookmarkIcon: UIImageView!
    var eventTitle = UILabel()
    var performerName = UILabel()
        
    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = GlobalCornerRadius.value
        
        gradientBg.layer.cornerRadius = GlobalCornerRadius.value
        gradientBg.layer.insertSublayer(GradientLayer.create(frame: CGRect(x: 0, y: 0, width: Self.width, height: Self.height), colors: [.random, .random], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5), cornerRadius: true), at: 0)
        gradientBg.backgroundColor = .clear
        gradientBg.alpha = 0.575
        
        bgImgView.layer.cornerRadius = GlobalCornerRadius.value
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.clipsToBounds = true
        
        eventTitle.textColor = .white
        eventTitle.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        eventTitle.numberOfLines = 0
        eventTitle.textAlignment = .center
        containerView.addSubview(eventTitle)
        eventTitle.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(5)
            make.width.equalTo(UIScreen.main.bounds.width - 80)
            make.centerX.equalToSuperview()
        }
        
        performerName.textColor = UIColor(hexString: "#e7e7e7")
        performerName.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        performerName.numberOfLines = 1
        performerName.textAlignment = .center
        containerView.addSubview(performerName)
        performerName.snp.makeConstraints { (make) in
            make.top.equalTo(eventTitle.snp.bottom).offset(3)
            make.width.equalToSuperview()
            make.left.right.equalTo(0)
        }
    }

}
