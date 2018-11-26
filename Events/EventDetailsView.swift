//
//  EventDetailsView.swift
//  major-7-ios
//
//  Created by jason on 26/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class EventDetailsView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("EventDetailsView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.backgroundColor = .darkGray
        contentView.layer.cornerRadius = GlobalCornerRadius.value + 4
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
