//
//  MapMarkerView.swift
//  major-7-ios
//
//  Created by jason on 29/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import GoogleMaps

class MapMarker: GMSMarker {
    
    var nameBg = UIView()
    var performerName = UILabel()
    var markerImg = UIImageView()
    var performerIcon = UIImageView()
    
    init(name: String) {
        super.init()
        
        let iconView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 80)))
        iconView.backgroundColor = .clear
        
        nameBg.backgroundColor = .m7DarkGray()
        nameBg.layer.cornerRadius = 5
        iconView.addSubview(nameBg)
        nameBg.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalTo(19)
            make.width.equalTo(80)
            make.left.right.equalTo(0)
        }
        
        performerName.text = name
        performerName.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        performerName.textColor = .white
        performerName.numberOfLines = 1
        performerName.adjustsFontSizeToFitWidth = true
        performerName.minimumScaleFactor = 0.5
        performerName.textAlignment = .center
        nameBg.addSubview(performerName)
        performerName.snp.makeConstraints { (make) in
            make.width.equalTo(70)
            make.center.equalTo(nameBg)
        }

        markerImg.contentMode = .scaleAspectFill
        markerImg.clipsToBounds = true
        markerImg.image = UIImage(named: "map_marker")
        iconView.addSubview(markerImg)
        markerImg.snp.makeConstraints { (make) in
            make.size.equalTo(60)
            make.top.equalTo(nameBg.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
        
        performerIcon.contentMode = .scaleAspectFill
        performerIcon.clipsToBounds = true
        performerIcon.layer.cornerRadius = 18
        performerIcon.backgroundColor = .darkGray
        iconView.addSubview(performerIcon)
        performerIcon.snp.makeConstraints { (make) in
            make.size.equalTo(36)
            make.top.equalTo(markerImg.snp.top).offset(5)
            make.centerX.equalToSuperview()
        }
        
        self.iconView = iconView
    }
}
