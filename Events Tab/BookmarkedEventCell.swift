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
    
    var loadingIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 10, height: 10)), type: .lineScale)
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var gradientBg: UIView!
    @IBOutlet weak var bookmarkCount: UILabel!
    @IBOutlet weak var bookmarkIcon: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var perfomerName: UILabel!
    
    @IBOutlet var viewsToShowLater: Array<UIView>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for view in viewsToShowLater {
            view.alpha = 0
        }
        
        loadingIndicator.startAnimating()
        addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.size.equalTo(10)
            make.top.equalTo(10)
            make.right.equalTo(-10)
        }
        
        containerView.layer.cornerRadius = GlobalCornerRadius.value
        
        gradientBg.layer.cornerRadius = GlobalCornerRadius.value
        gradientBg.layer.insertSublayer(GradientLayer.create(frame: CGRect(x: 0, y: 0, width: Self.width, height: Self.height), colors: [.random, .random], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5), cornerRadius: true), at: 0)
        gradientBg.backgroundColor = .clear
        gradientBg.alpha = 0.55
        
        bgImgView.layer.cornerRadius = GlobalCornerRadius.value
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.clipsToBounds = true
    }

}
