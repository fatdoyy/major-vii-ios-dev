//
//  OnboardingGenreCell.swift
//  major-7-ios
//
//  Created by jason on 2/1/2020.
//  Copyright © 2020 Major VII. All rights reserved.
//

import UIKit

class OnboardingGenreCell: UICollectionViewCell {
    static let reuseIdentifier = "onboardingGenreCell"
    
    static let height: CGFloat = 40
    
    @IBOutlet weak var genre: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        layer.cornerRadius = 20
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        
        genre.textColor = UIColor.white.withAlphaComponent(0.75)
        genre.numberOfLines = 1
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                backgroundColor = .white
                genre.textColor = UIColor(hexString: "#3c1053")
                Animations.cellBounce(isSelected, view: self)
            }
            else {
                backgroundColor = .clear
                genre.textColor = UIColor.white.withAlphaComponent(0.75)
                Animations.cellBounce(isSelected, view: self)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        genre.textColor = UIColor.white.withAlphaComponent(0.75)
        backgroundColor = .clear
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
    }
}
