//
//  NewsSection.swift
//  major-7-ios
//
//  Created by jason on 24/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

protocol NewsSectionHeaderDelegate {
    func newsBtnTapped()
    func postsBtnTapped()
}

class NewsSectionHeader: UICollectionReusableView {

    var delegate: NewsSectionHeaderDelegate?
    
    static let reuseIdentifier: String = "newsHeader"
    
    static let height: CGFloat = 74 //height form xib frame
    
    @IBOutlet weak var newsBtn: UIButton!
    @IBOutlet weak var postsBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        newsBtn.setTitle("News", for: .normal)
        newsBtn.setTitleColor(.white, for: .normal)
        newsBtn.backgroundColor = UIColor(hexString: "#348ac7")
        newsBtn.layer.cornerRadius = 41 / 2
        
        postsBtn.setTitle("Posts", for: .normal)
        postsBtn.setTitleColor(.whiteText25Alpha(), for: .normal)
    }
    
    @IBAction func newsBtnTapped(_ sender: Any) {
        delegate?.newsBtnTapped()
    }
    
    @IBAction func postsBtnTapped(_ sender: Any) {
        delegate?.postsBtnTapped()
    }
}
