//
//  NewsSectionFooter.swift
//  major-7-ios
//
//  Created by jason on 24/4/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class NewsSectionFooter: UICollectionReusableView {

    static let reuseIdentifier: String = "newsFooter"
    
    static let height: CGFloat = 40 //height form xib frame
    
    @IBOutlet weak var sepLine: UIView!
    @IBOutlet weak var copyrightLabel: UILabel!
    
    var loadingIndicator: NVActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .m7DarkGray()
        
        sepLine.alpha = 0
        sepLine.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        sepLine.layer.cornerRadius = 0.2
        
        copyrightLabel.alpha = 0
        copyrightLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        copyrightLabel.textColor = .lightGrayText()
        copyrightLabel.text = "Copyright © 2021 | Major VII | ALL RIGHTS RESERVED"
        
        loadingIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)), type: .lineScale)
        loadingIndicator.startAnimating()
        addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(20)
        }
    }
    
}
