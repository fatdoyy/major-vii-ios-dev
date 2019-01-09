//
//  LoginView.swift
//  major-7-ios
//
//  Created by jason on 3/1/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import SwiftGifOrigin
import SkyFloatingLabelTextField
import Localize_Swift

protocol LoginViewDelegate{
    func didTapFbLogin()
    func didTapGoogleLogin()
    func didTapEmailLogin()
}

class LoginView: UIView {
    
    var delegate: LoginViewDelegate?
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var videoBg: UIImageView!
    @IBOutlet weak var videoOverlay: UIView!
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    
    //MARK: Social Login Elements
    @IBOutlet weak var fbLoginBtn: UIButton!
    @IBOutlet weak var googleLoginBtn: UIButton!
    @IBOutlet weak var emailLoginLabel: UILabel!
    @IBOutlet weak var registerBtn: UIButton!
    
    /*MARK: Email Login Elements
      Note: all view's hierarchy is below Social Login Elements
     */
    @IBOutlet weak var loginActionBtn: UIButton!
    @IBOutlet weak var emailTextFieldBg: UIView!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    
    
    @IBOutlet weak var seperatorLine: UIView!
    @IBOutlet weak var emailLoginBtn: UIButton!

    
    @IBOutlet weak var tcLabel: UILabel!
    
    @IBOutlet var socialLoginElements: Array<UIView>!
    @IBOutlet var emailLoginElements: Array<UIView>!

    var gifIndex: String?
    
    //Note: these thumbnails are in the .xcassets file, not "GIFs" folder, since these are JPGs
    let gifThumbnail: [UIImage] = [UIImage(named: "gif0_thumbnail")!, UIImage(named: "gif1_thumbnail")!, UIImage(named: "gif2_thumbnail")!, UIImage(named: "gif3_thumbnail")!, UIImage(named: "gif4_thumbnail")!, UIImage(named: "gif5_thumbnail")!, UIImage(named: "gif6_thumbnail")!, UIImage(named: "gif7_thumbnail")!, UIImage(named: "gif8_thumbnail")!, UIImage(named: "gif9_thumbnail")!, UIImage(named: "gif10_thumbnail")!, UIImage(named: "gif11_thumbnail")!]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(loadXibView(with: bounds))
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(loadXibView(with: bounds))
        setupUI()
    }

    private func setupUI(){
        contentView.backgroundColor = .darkGray
        
        videoOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        
        let randomIndex = Int(arc4random_uniform(UInt32(gifThumbnail.count))) // not using .randomElemnt() here beacuse we will need the index
        gifIndex = "gif\(randomIndex)"
        videoBg.image = gifThumbnail[randomIndex]
    
        descLabel.textColor = .whiteText()
        
        setupSocialLoginElements()
        setupEmailLoginElements()
        setupRegisterElements()
        
        seperatorLine.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        emailLoginBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
        emailLoginBtn.setTitleColor(.white, for: .selected)
        tcLabel.textColor = .whiteText50Alpha()
    }
    
    private func setupSocialLoginElements() {
        fbLoginBtn.backgroundColor = .fbBlue()
        fbLoginBtn.layer.cornerRadius = GlobalCornerRadius.value
        fbLoginBtn.setTitleColor(.white, for: .normal)
        
        googleLoginBtn.backgroundColor = .white
        googleLoginBtn.layer.cornerRadius = GlobalCornerRadius.value
        googleLoginBtn.setTitleColor(.darkGrayText(), for: .normal)
        
        emailLoginLabel.textColor = .whiteText()
        
        //create blur effect for register button
        let containerView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        containerView.layer.cornerRadius = GlobalCornerRadius.value
        containerView.clipsToBounds = true
        containerView.frame = registerBtn.bounds
        containerView.isUserInteractionEnabled = false
        
        registerBtn.layer.cornerRadius = GlobalCornerRadius.value
        registerBtn.backgroundColor = .clear
        registerBtn.insertSubview(containerView, belowSubview: registerBtn.titleLabel!)
        registerBtn.setTitleColor(.white, for: .normal)
    }
    
    private func setupEmailLoginElements() {
        //create blur effect for emailTextFieldBg
        let containerView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        containerView.layer.cornerRadius = GlobalCornerRadius.value
        containerView.clipsToBounds = true
        containerView.frame = emailTextFieldBg.bounds
        containerView.isUserInteractionEnabled = false
        
        emailTextFieldBg.layer.cornerRadius = GlobalCornerRadius.value
        emailTextFieldBg.backgroundColor = .clear
        emailTextFieldBg.addSubview(containerView)
        
        emailTextField.placeholder = "admin@majorvii.com"
        emailTextField.placeholderFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        emailTextField.title = "Email"
        emailTextField.titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        emailTextField.selectedTitleColor = .lightPurple()
        emailTextField.titleFormatter = { $0 } //disable title uppercase
        emailTextField.textColor = .whiteText80Alpha()
        emailTextField.lineHeight = 1
        emailTextField.lineColor = .darkGray
        emailTextField.selectedLineHeight = 1.5
        emailTextField.selectedLineColor = .lightGray
        
        loginActionBtn.layer.cornerRadius = GlobalCornerRadius.value
        loginActionBtn.backgroundColor = .red
        loginActionBtn.setTitleColor(.white, for: .normal)
        
//        for view in emailLoginElements { //these views will be shown later
//            view.alpha = 0
//        }
    }
    
    private func setupRegisterElements() {}
    
    @IBAction func didTapFbLogin(_ sender: Any) {
        delegate?.didTapFbLogin()
    }

    @IBAction func didTapGoogleLogin(_ sender: Any) {
        delegate?.didTapGoogleLogin()
    }
    
    @IBAction func didTapEmailLogin(_ sender: Any) {
        delegate?.didTapEmailLogin()
    }
    
}
