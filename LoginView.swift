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
import Pastel
import Localize_Swift

protocol LoginViewDelegate{
    func didTapFbLogin()
    func didTapGoogleLogin()
    func didTapEmailLogin()
    func didTapLoginAction()
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
    var loginActionBtnGradientBg = PastelView()
    @IBOutlet weak var loginActionBtn: UIButton!
    @IBOutlet weak var emailTextFieldBg: UIView!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var pwTextFieldBg: UIView!
    @IBOutlet weak var pwTextField: SkyFloatingLabelTextField!
    
    
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
        containerView.isUserInteractionEnabled = false

        registerBtn.layer.cornerRadius = GlobalCornerRadius.value
        registerBtn.backgroundColor = .clear
        registerBtn.insertSubview(containerView, belowSubview: registerBtn.titleLabel!)
        
        containerView.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(registerBtn.snp.center)
            make.width.equalTo(UIScreen.main.bounds.size.width - 80)
            make.height.equalTo(registerBtn.bounds.height)
        }
        registerBtn.setTitleColor(.white, for: .normal)
    }
    
    private func setupEmailLoginElements() {
        //create blur effect for emailTextFieldBg
        let containerView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        containerView.layer.cornerRadius = GlobalCornerRadius.value
        containerView.clipsToBounds = true
        containerView.isUserInteractionEnabled = false
        
        emailTextFieldBg.layer.cornerRadius = GlobalCornerRadius.value
        emailTextFieldBg.backgroundColor = .clear
        emailTextFieldBg.insertSubview(containerView, belowSubview: emailTextField)
        
        containerView.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(emailTextFieldBg.snp.center)
            make.width.equalTo(UIScreen.main.bounds.size.width - 80)
            make.height.equalTo(emailTextFieldBg.bounds.height)
        }
        
        emailTextField.delegate = self
        emailTextField.placeholder = "Email"
        emailTextField.placeholderFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        emailTextField.title = "Email"
        emailTextField.titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        emailTextField.titleColor = .darkPurple()
        emailTextField.selectedTitleColor = .lightPurple()
        emailTextField.titleFormatter = { $0 } //disable title uppercase
        emailTextField.textColor = .whiteText80Alpha()
        emailTextField.lineHeight = 1.25
        emailTextField.lineColor = .white15Alpha()
        emailTextField.selectedLineHeight = 1.5
        emailTextField.selectedLineColor = .white50Alpha()
        
        //create blur effect for pwTextFieldBg
        let containerView2 = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        containerView2.layer.cornerRadius = GlobalCornerRadius.value
        containerView2.clipsToBounds = true
        containerView2.isUserInteractionEnabled = false
     
        pwTextFieldBg.layer.cornerRadius = GlobalCornerRadius.value
        pwTextFieldBg.backgroundColor = .clear
        pwTextFieldBg.insertSubview(containerView2, at: 0)
        
        containerView2.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(pwTextFieldBg.snp.center)
            make.width.equalTo(UIScreen.main.bounds.size.width - 80)
            make.height.equalTo(pwTextFieldBg.bounds.height)
        }
        
        pwTextField.delegate = self
        pwTextField.placeholder = "Password"
        pwTextField.placeholderFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        pwTextField.title = "Password"
        pwTextField.titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        pwTextField.titleColor = .darkPurple()
        pwTextField.selectedTitleColor = .lightPurple()
        pwTextField.titleFormatter = { $0 } //disable title uppercase
        pwTextField.textColor = .whiteText80Alpha()
        pwTextField.lineHeight = 1.25
        pwTextField.lineColor = .white15Alpha()
        pwTextField.selectedLineHeight = 1.5
        pwTextField.selectedLineColor = .white50Alpha()
        
        //gradient for loginActionBtn

        loginActionBtnGradientBg.startPastelPoint = .topLeft
        loginActionBtnGradientBg.endPastelPoint = .bottomRight
        loginActionBtnGradientBg.animationDuration = 3
        loginActionBtnGradientBg.isUserInteractionEnabled = false
        loginActionBtnGradientBg.setColors([
                              UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
                              UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0),
                              UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0)])
        
        loginActionBtn.clipsToBounds = true
        loginActionBtn.layer.cornerRadius = GlobalCornerRadius.value
        loginActionBtn.setTitleColor(.white, for: .normal)
        
        loginActionBtn.insertSubview(loginActionBtnGradientBg, at: 0)
        loginActionBtnGradientBg.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(loginActionBtn.snp.center)
            make.width.equalTo(loginActionBtn.bounds.width)
            make.height.equalTo(loginActionBtn.bounds.height)
        }
        
        for view in emailLoginElements { //these views will be shown later
            view.alpha = 0
            view.isUserInteractionEnabled = false
        }
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
    
    @IBAction func didTapLoginAction(_ sender: Any) {
        delegate?.didTapLoginAction()
    }
    
}

extension LoginView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
