//
//  InfoWindow.swift
//  major-7-ios
//
//  Created by jason on 29/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class InfoWindow: UIView {
    
    var eventTitle = UILabel()
    var date = UILabel()
    var bookmarkIcon = UIImageView()
    var bookmarkCount = UILabel()
    
    init(eventTitle: String, date: String, bookmarkCount: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 60, height: 160))
        alpha = 0
        backgroundColor = .darkGray()
        layer.cornerRadius = GlobalCornerRadius.value

        
        return
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

}
