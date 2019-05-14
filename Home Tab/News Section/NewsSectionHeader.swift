//
//  NewsSection.swift
//  major-7-ios
//
//  Created by jason on 24/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit


protocol NewsSectionHeaderDelegate {
    func newsBtnTapped(sender: UIButton)
    func postsBtnTapped(sender: UIButton)
}

class NewsSectionHeader: UICollectionReusableView {

    var delegate: NewsSectionHeaderDelegate?
    
    static let reuseIdentifier: String = "newsHeader"
    
    static let height: CGFloat = 74 //height form xib frame
    
    @IBOutlet weak var newsBtn: UIButton!
    @IBOutlet weak var postsBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        let radius: CGFloat = 41 / 2
        
        newsBtn.setTitle("News", for: .normal)
        newsBtn.setTitleColor(.white, for: .normal)
        newsBtn.backgroundColor = .random
        newsBtn.layer.cornerRadius = radius
        
        postsBtn.setTitle("Posts", for: .normal)
        postsBtn.setTitleColor(.whiteText25Alpha(), for: .normal)
        postsBtn.layer.cornerRadius = radius
    }
    
    @IBAction func newsBtnTapped(_ sender: UIButton) {
        delegate?.newsBtnTapped(sender: sender)
        
        //postsBtn animation
        UIView.transition(with: postsBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.postsBtn.setTitleColor(.whiteText25Alpha(), for: .normal)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.2) {
            self.postsBtn.backgroundColor = .clear
        }
        
        //newsBtn animation
        UIView.transition(with: newsBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.newsBtn.setTitleColor(.white, for: .normal)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.2) {
            self.newsBtn.backgroundColor = .random
        }
    }
    
    @IBAction func postsBtnTapped(_ sender: UIButton) {
        delegate?.postsBtnTapped(sender: sender)
        
        //postsBtn animation
        UIView.transition(with: postsBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.postsBtn.setTitleColor(.white, for: .normal)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.2) {
            self.postsBtn.backgroundColor = .random
        }
        
        //newsBtn animation
        UIView.transition(with: newsBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.newsBtn.setTitleColor(.whiteText25Alpha(), for: .normal)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.2) {
            self.newsBtn.backgroundColor = .clear
        }
    }
}
