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
    
    var gifIndex: String?
    
    //Note: these thumbnails are in the .xcassets file, not "GIFs" folder, since these are JPGs
    let gifThumbnail: [UIImage] = [UIImage(named: "gif0_thumbnail")!, UIImage(named: "gif1_thumbnail")!, UIImage(named: "gif2_thumbnail")!, UIImage(named: "gif3_thumbnail")!, UIImage(named: "gif4_thumbnail")!, UIImage(named: "gif5_thumbnail")!, UIImage(named: "gif6_thumbnail")!, UIImage(named: "gif7_thumbnail")!, UIImage(named: "gif8_thumbnail")!, UIImage(named: "gif9_thumbnail")!, UIImage(named: "gif10_thumbnail")!, UIImage(named: "gif11_thumbnail")!]
    
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
        
        videoOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        let randomIndex = Int(arc4random_uniform(UInt32(gifThumbnail.count))) // not using .randomElemnt() here beacuse we will need the index
        gifIndex = "gif\(randomIndex)"
        videoBg.image = gifThumbnail[randomIndex]
    
        descLabel.textColor = .whiteText()
        
        fbLoginBtn.backgroundColor = .fbBlue()
        fbLoginBtn.layer.cornerRadius = GlobalCornerRadius.value
        fbLoginBtn.setTitleColor(.white, for: .normal)
        
        googleLoginBtn.backgroundColor = .white
        googleLoginBtn.layer.cornerRadius = GlobalCornerRadius.value
        googleLoginBtn.setTitleColor(.darkGrayText(), for: .normal)
        
        emailLoginLabel.textColor = .whiteText()
    
        //create blur effect for login/register buttons
        let containerView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        containerView.layer.cornerRadius = GlobalCornerRadius.value
        containerView.clipsToBounds = true
        containerView.frame = emailLoginBtn.bounds
        containerView.isUserInteractionEnabled = false
        
        emailLoginBtn.layer.cornerRadius = GlobalCornerRadius.value
        emailLoginBtn.backgroundColor = .clear
        emailLoginBtn.insertSubview(containerView, belowSubview: emailLoginBtn.titleLabel!)
        emailLoginBtn.setTitleColor(.white, for: .normal)

        let containerView2 = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        containerView2.layer.cornerRadius = GlobalCornerRadius.value
        containerView2.clipsToBounds = true
        containerView2.frame = emailLoginBtn.bounds
        containerView2.isUserInteractionEnabled = false
        
        registerBtn.layer.cornerRadius = GlobalCornerRadius.value
        registerBtn.backgroundColor = .clear
        registerBtn.insertSubview(containerView2, belowSubview: registerBtn.titleLabel!)
        registerBtn.setTitleColor(.white, for: .normal)
        
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
