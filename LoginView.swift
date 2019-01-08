//
//  LoginView.swift
//  major-7-ios
//
//  Created by jason on 3/1/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import SwiftGifOrigin
import Localize_Swift

protocol LoginViewDelegate{
    func fbLoginPressed()
    func googleLoginPressed()
}

class LoginView: UIView {
    
    var delegate: LoginViewDelegate?
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var videoBg: UIImageView!
    @IBOutlet weak var videoOverlay: UIView!
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var fbLoginBtn: UIButton!
    @IBOutlet weak var googleLoginBtn: UIButton!
    
    @IBOutlet weak var emailLoginLabel: UILabel!
    
    @IBOutlet weak var emailLoginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var seperatorLine: UIView!
    
    @IBOutlet weak var guestLoginBtn: UIButton!
    
    @IBOutlet weak var tcLabel: UILabel!
    
    let GIFs: [UIImage] = [UIImage.gif(name: "gif0")!, UIImage.gif(name: "gif1")!, UIImage.gif(name: "gif2")!, UIImage.gif(name: "gif3")!, UIImage.gif(name: "gif4")!, UIImage.gif(name: "gif5")!, UIImage.gif(name: "gif6")!, UIImage.gif(name: "gif7")!, UIImage.gif(name: "gif8")!, UIImage.gif(name: "gif9")!, UIImage.gif(name: "gif10")!]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit(){
        Bundle.main.loadNibNamed("LoginView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.backgroundColor = .darkGray
        
        videoOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        
        let gif = GIFs.randomElement()
        videoBg.image = gif
        
        descLabel.textColor = .whiteText()
        emailLoginLabel.textColor = .whiteText()
        
        seperatorLine.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        guestLoginBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
        tcLabel.textColor = .whiteText50Alpha()
    }
    
    @IBAction func fbLoginPressed(_ sender: Any) {
        delegate?.fbLoginPressed()
    }

    @IBAction func googleLoginPressed(_ sender: Any) {
        delegate?.googleLoginPressed()
    }
}
