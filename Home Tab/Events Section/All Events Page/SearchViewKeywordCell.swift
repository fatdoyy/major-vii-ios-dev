//
//  SearchViewKeywordCell.swift
//  major-7-ios
//
//  Created by jason on 24/8/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class SearchViewKeywordCell: UICollectionViewCell {
    static let reuseIdentifier = "searchViewKeywordCell"
    
    static let height: CGFloat = 24
    
    var keyword: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor(hexString: "#7e7ecf").withAlphaComponent(0.2)
        layer.cornerRadius = GlobalCornerRadius.value / 1.5
        
        keyword = UILabel()
        keyword.textColor = .purpleText()
        keyword.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        addSubview(keyword)
        keyword.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(24)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        keyword.textColor = .purpleText()
        backgroundColor = UIColor(hexString: "#7e7ecf").withAlphaComponent(0.2)
    }

}
