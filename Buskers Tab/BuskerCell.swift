//
//  BuskerCell.swift
//  major-7-ios
//
//  Created by jason on 19/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import SkeletonView

class BuskerCell: UICollectionViewCell {
    static let reuseIdentifier = "buskerCell"
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var buskerName: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var verifiedIcon: UIImageView!
    
    @IBOutlet var skeletonViews: Array<UIView>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = GlobalCornerRadius.value
        setupUI()
        setupSkeletonView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setupSkeletonView()
        buskerName.text = ""
        genre.text = ""
        imgView.image = nil
        verifiedIcon.alpha = 0
    }
}

//MARK: - UI related
extension BuskerCell {
    private func setupUI() {
        containerView.backgroundColor = .m7DarkGray()
        
        imgView.backgroundColor = .darkGray
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = GlobalCornerRadius.value
        imgView.clipsToBounds = true
        
        buskerName.numberOfLines = 1
        buskerName.textColor = .white
        
        genre.numberOfLines = 1
        genre.textColor = .white
        
        verifiedIcon.alpha = 0
    }
    
    func setupSkeletonView() {
        //skeleton view
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 2)
        buskerName.tag = 1
        for view in skeletonViews{
            if view.tag == 1 {
                SkeletonAppearance.default.multilineHeight = 14
            } else {
                SkeletonAppearance.default.multilineHeight = 11
            }
            view.isSkeletonable = true
            view.showAnimatedGradientSkeleton(animation: animation)
        }
    }
}
