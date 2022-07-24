//
//  GenreCell.swift
//  major-7-ios
//
//  Created by jason on 22/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class GenreCell: UICollectionViewCell {

    static let reuseIdentifier = "genreCell"
    static let width: CGFloat = 198
    static let aspectRatio: CGFloat = width / 96
    static let height: CGFloat = width / aspectRatio
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var gradientBg: UIView!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var trendingIcon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = GlobalCornerRadius.value
        
        gradientBg.layer.insertSublayer(GradientLayer.create(frame: gradientBg.bounds, colors: [.random, .random], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5), cornerRadius: true), at: 0)
        gradientBg.backgroundColor = .clear
        gradientBg.alpha = 0.4
        
        bgImgView.layer.cornerRadius = GlobalCornerRadius.value
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.clipsToBounds = true
        
        genre.textColor = .white
    }

}
