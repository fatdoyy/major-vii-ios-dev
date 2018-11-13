//
//  EventsCell.swift
//  major-7-ios
//
//  Created by jason on 24/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class EventsCell: UICollectionViewCell {

    static let reuseIdentifier: String = "eventCell"
    
    static let width: CGFloat = 198
    static let height: CGFloat = 96
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var performerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .darkGray()
        setupLabels()
        
        let layer = CAGradientLayer()
        layer.colors = [UIColor.lightPurple().cgColor, UIColor.darkPurple().cgColor]
        layer.frame = bgView.bounds
        layer.cornerRadius = GlobalCornerRadius.value
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        bgView.layer.insertSublayer(layer, at: 0)
        //sendSubviewToBack(bgView)
    }

    private func setupLabels(){
        dateLabel.text = "31 Apr"
        eventLabel.text = "Clockenflap @ 中環 feat. Jay Lee, jamistry"
        performerLabel.text = "Clockenflap"
        
        dateLabel.textColor = .whiteText()
        eventLabel.textColor = .whiteText()
        performerLabel.textColor = .whiteText()
    }
}
