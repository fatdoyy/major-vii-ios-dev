//
//  PostImageCell.swift
//  major-7-ios
//
//  Created by jason on 15/7/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class PostImageCell: UICollectionViewCell {

    static let reuseIdentifier = "postImageCell"
    
    @IBOutlet weak var imgOverlay: UIView!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgView.backgroundColor = .darkGray
        imgView.layer.cornerRadius = GlobalCornerRadius.value / 2
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        
        //        imgOverlay.backgroundColor = .clear
        //        imgOverlay.layer.insertSublayer(GradientLayer.create(frame: imgView!.bounds, colors: [.darkGray(), UIColor.white.withAlphaComponent(0)], startPoint: CGPoint(x: 0.5, y: 1), endPoint: CGPoint(x: 0.5, y: 0)), at: 0)
        //        imgOverlay.snp.makeConstraints { (make) -> Void in
        //            make.edges.equalToSuperview()
        //        }
    }

}
