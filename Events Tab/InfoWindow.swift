//
//  InfoWindow.swift
//  major-7-ios
//
//  Created by jason on 29/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

protocol InfoWindowDelegate {
    func infoWindowMoreBtnTapped()
}

class InfoWindow: UIView {
    var delegate: InfoWindowDelegate?
    
    static var width: CGFloat = UIScreen.main.bounds.width - 80
    static var aspectRatio: CGFloat = width / 190
    static var height: CGFloat = width / aspectRatio
    
    var eventID: String?
    var titleLabel = UILabel()
    var detailsLabel = UILabel()

    var distanceBg = UIView()
    var distanceIcon = UIImageView()
    var distanceLabel = UILabel()
    
    var dateTimeIcon = UIImageView()
    var dateTimeLabel = UILabel()
    
    var venueIcon = UIImageView()
    var venueLabel = UILabel()
    
    var moreBtn = UIButton()
    
    init(eventTitle: String, date: String, desc: String, venue: String, distance: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: InfoWindow.width, height: InfoWindow.height))
        alpha = 0
        dropShadow(color: .black, opacity: 0.65, offSet: CGSize(width: -1, height: 1), radius: GlobalCornerRadius.value, scale: true)
        backgroundColor = UIColor(hexString: "#11998E")
        layer.cornerRadius = GlobalCornerRadius.value

        titleLabel.numberOfLines = 2
        titleLabel.text = eventTitle
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//        title.adjustsFontSizeToFitWidth = true
//        title.minimumScaleFactor = 0.6
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.centerX.equalToSuperview()
        }
        
        detailsLabel.numberOfLines = 3
        detailsLabel.text = desc
        detailsLabel.textColor = .white
        detailsLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        addSubview(detailsLabel)
        detailsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        moreBtn.setTitle("More", for: .normal)
        moreBtn.setTitleColor(.white, for: .normal)
        moreBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        moreBtn.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        moreBtn.layer.cornerRadius = GlobalCornerRadius.value / 3
        moreBtn.addTarget(self, action: #selector(moreBtnTapped), for: .touchUpInside)
        addSubview(moreBtn)
        moreBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-12)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(22)
            make.width.equalTo(53)
        }
        
        venueIcon.image = UIImage(named: "icon_venue")
        addSubview(venueIcon)
        venueIcon.snp.makeConstraints { (make) in
            make.size.equalTo(12)
            make.bottom.equalToSuperview().offset(-14)
            make.left.equalToSuperview().offset(15)
        }
        
        venueLabel.numberOfLines = 1
        venueLabel.text = venue
        venueLabel.textColor = .white
        venueLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        addSubview(venueLabel)
        venueLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-13)
            make.left.equalTo(venueIcon.snp.right).offset(3)
            make.right.equalTo(moreBtn.snp.left).offset(-15)
        }
        
        dateTimeIcon.image = UIImage(named: "icon_date")
        addSubview(dateTimeIcon)
        dateTimeIcon.snp.makeConstraints { (make) in
            make.size.equalTo(12)
            make.bottom.equalTo(venueLabel.snp.top).offset(-6)
            make.left.equalToSuperview().offset(15)
        }
        
        dateTimeLabel.numberOfLines = 2
        dateTimeLabel.text = date
        dateTimeLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        guard let creditCardFont = UIFont(name: "CreditCard", size: 9) else { fatalError("can't load font") }
        dateTimeLabel.font = UIFontMetrics.default.scaledFont(for: creditCardFont)
        dateTimeLabel.adjustsFontForContentSizeCategory = true
        addSubview(dateTimeLabel)
        dateTimeLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(venueLabel.snp.top).offset(-5)
            make.left.equalTo(dateTimeIcon.snp.right).offset(3)
            make.right.equalToSuperview().offset(-15)
        }
        
        distanceBg.backgroundColor = .white
        distanceBg.layer.cornerRadius = 4
        addSubview(distanceBg)
        distanceBg.snp.makeConstraints { (make) in
            make.width.equalTo(52)
            make.height.equalTo(18)
            make.left.equalToSuperview().offset(15)
            make.bottom.equalTo(dateTimeLabel.snp.top).offset(-6)
        }
        
        distanceIcon.image = UIImage(named: "icon_distance")
        distanceBg.addSubview(distanceIcon)
        distanceIcon.snp.makeConstraints { (make) in
            make.size.equalTo(12)
            make.centerY.equalToSuperview()
            make.left.equalTo(snp.left).offset(16)
        }
        
        distanceLabel.numberOfLines = 1
        distanceLabel.text = distance
        distanceLabel.textColor = UIColor(hexString: "#11998E")
        distanceLabel.font = UIFontMetrics.default.scaledFont(for: creditCardFont)
        distanceLabel.adjustsFontForContentSizeCategory = true
        distanceBg.addSubview(distanceLabel)
        distanceLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(1)
            make.right.equalTo(distanceBg.snp.right).offset(-4)
        }
        
        return
    }
    
    @objc func moreBtnTapped() {
        delegate?.infoWindowMoreBtnTapped()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

}
