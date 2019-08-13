//
//  BuskerProfilePostCell.swift
//  major-7-ios
//
//  Created by jason on 12/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class BuskerProfilePostCell: UICollectionViewCell {

    static let reuseIdentifier = "buskerProfilePostCell"
    static let width: CGFloat = UIScreen.main.bounds.width - 80
    static let height: CGFloat = 422
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var buskerIcon: UIImageView!
    @IBOutlet weak var buskerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var moreIcon: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    var postImg = UIImageView()
    var statsLabel = UILabel()
    var clapBtn = UIButton()
    var commentBtn = UIButton()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.layer.cornerRadius = GlobalCornerRadius.value / 2
        bgView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        
        buskerIcon.layer.cornerRadius = 32
        buskerLabel.textColor = .white
        dateLabel.textColor = .white
        contentLabel.textColor = .white
        
        setupNonXibUI()
    }

    private func setupNonXibUI() {
        clapBtn.layer.cornerRadius = GlobalCornerRadius.value / 2
        clapBtn.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        clapBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        clapBtn.setTitle("拍手", for: .normal)
        addSubview(clapBtn)
        clapBtn.snp.makeConstraints { (make) -> Void in
            make.bottom.equalToSuperview().offset(-15)
            make.width.equalTo(UIScreen.main.bounds.width / 2 - 65)
            make.height.equalTo(28)
            make.left.equalToSuperview().offset(20)
        }
        
        commentBtn.layer.cornerRadius = GlobalCornerRadius.value / 2
        commentBtn.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        commentBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        commentBtn.setTitle("留言", for: .normal)
        addSubview(commentBtn)
        commentBtn.snp.makeConstraints { (make) -> Void in
            make.bottom.equalToSuperview().offset(-15)
            make.width.equalTo(UIScreen.main.bounds.width / 2 - 65)
            make.height.equalTo(28)
            make.right.equalToSuperview().offset(-20)
        }
        
        statsLabel.textColor = .whiteText50Alpha()
        statsLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        addSubview(statsLabel)
        statsLabel.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(commentBtn.snp.top).offset(-10)
            make.width.equalTo(UIScreen.main.bounds.width - 120)
            make.height.equalTo(17)
            make.centerX.equalToSuperview()
        }
        
        postImg.contentMode = .scaleAspectFill
        postImg.image = UIImage(named: "cat")
        postImg.clipsToBounds = true
        postImg.layer.cornerRadius = GlobalCornerRadius.value / 2
        addSubview(postImg)
        postImg.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentLabel.snp.bottom).offset(15)
            make.width.equalTo(UIScreen.main.bounds.width - 120)
            make.bottom.equalTo(statsLabel.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }
        
    }
}
