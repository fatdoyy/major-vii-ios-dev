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
    
    var titleLabel = UILabel()
    var dateTimeLabel = UILabel()
    var detailsLabel = UILabel()
    var venueLabel = UILabel()
    var moreBtn = UIButton()
    
    init(eventTitle: String, date: String, desc: String, venue: String, bookmarkCount: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: InfoWindow.width, height: InfoWindow.height))
        alpha = 0
        dropShadow(color: .black, opacity: 0.7, offSet: CGSize(width: -1, height: 1), radius: GlobalCornerRadius.value, scale: true)
        backgroundColor = UIColor(hexString: "#11998E")
        layer.cornerRadius = GlobalCornerRadius.value

        titleLabel.numberOfLines = 2
        titleLabel.text = eventTitle
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
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
        detailsLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
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

        
        dateTimeLabel.numberOfLines = 2
        dateTimeLabel.text = date
        dateTimeLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        dateTimeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        addSubview(dateTimeLabel)
        dateTimeLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-15)
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(moreBtn.snp.left).offset(-15)
        }
        
        venueLabel.numberOfLines = 1
        venueLabel.text = venue
        venueLabel.textColor = .white
        venueLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        addSubview(venueLabel)
        venueLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(dateTimeLabel.snp.top).offset(-5)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        
        return
    }
    
    @objc func moreBtnTapped() {
        print("tapped")
        delegate?.infoWindowMoreBtnTapped()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

}
