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
        backgroundColor = UIColor(hexString: "#7e7ecf").withAlphaComponent(0.2)
        layer.cornerRadius = 20
        
        genre.textColor = .purpleText()
        genre.numberOfLines = 1
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        genre.textColor = .purpleText()
        backgroundColor = UIColor(hexString: "#7e7ecf").withAlphaComponent(0.2)
    }
}
