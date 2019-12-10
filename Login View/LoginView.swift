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
import NVActivityIndicatorView
import AuthenticationServices

protocol LoginViewDelegate: class {
    func didTapDismissBtn()
    func didTapFbLogin()
    func didTapGoogleLogin()
    func didTapAppleSignIn()
    func didTapRegisterBtn()
    func didTapEmailLogin()
    func didTapLoginAction()
    func didTapRegAction()
}

class LoginView: UIView {
    weak var delegate: LoginViewDelegate?
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var videoBg: UIImageView!
    @IBOutlet weak var videoOverlay: UIView!
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    var isKeyboardPresent = false
    
    //MARK: - Social Login Elements
    var appleSignInBtn: Any? = {
        if #available(iOS 13.0, *) {
            return ASAuthorizationAppleIDButton(type: .signIn, style: .white)
        } else { return nil }
    }()
    @IBOutlet weak var fbLoginBtn: UIButton!
    @IBOutlet weak var googleLoginBtn: UIButton!
    @IBOutlet weak var emailLoginLabel: UILabel!
    var regActionBtnGradientBg = PastelView()
    @IBOutlet weak var regBtn: UIButton!
    
    //MARK: - Email Login Elements
    ///Note: all view's hierarchy is below Social Login Element
    @IBOutlet weak var emailTextFieldBg: UIView!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var pwTextFieldBg: UIView!
    @IBOutlet weak var pwTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var pwTextFieldBgBottomConstraint: NSLayoutConstraint!
    var loginActionBtnGradientBg = PastelView()
    @IBOutlet weak var loginActionBtn: UIButton!
    var loginActivityIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)))
    
    //MARK: - Register Elements
    ///Note: all view's hierarchy is below Social Login Elements
    @IBOutlet weak var regEmailTextFieldBg: UIView!
    @IBOutlet weak var regEmailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var regPwTextFieldBg: UIView!
    @IBOutlet weak var regPwTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var regPwRefillTextFieldBg: UIView!
    @IBOutlet weak var regPwRefillTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var regActionBtn: UIButton!
    var regActivityIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)))
    @IBOutlet weak var regPwRefillTextFieldBottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var seperatorLine: UIView!
    @IBOutlet weak var emailLoginBtn: UIButton!
    
    @IBOutlet weak var tcLabel: UILabel!
    
    @IBOutlet var socialLoginElements: Array<UIView>!
    @IBOutlet var emailLoginElements: Array<UIView>!
    @IBOutlet var registerElements: Array<UIView>!
    
    var gifIndex: String?
    
    //Note: these thumbnails are in the .xcassets file, not "GIFs" folder, since these are static images
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
    
    private func setupUI() {
        NotificationCenter.default.setObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        contentView.backgroundColor = .darkGray
        
        videoOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        
        let randomIndex = Int.random(in: 0 ..< gifThumbnail.count) // not using .randomElemnt() here beacuse we will need the index
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
        
        if #available(iOS 13.0, *) {} else {
            let dismissBtn2 = UIButton()
            dismissBtn2.setImage(UIImage(named: "icon_close"), for: .normal)
            dismissBtn2.addTarget(self, action: #selector(didTapDismissBtn), for: .touchUpInside)
            addSubview(dismissBtn2)
            dismissBtn2.snp.makeConstraints { (make) in
                if UIDevice.current.hasHomeButton { //if device is not iPhone X, XR, XS, XS Max
                    make.top.equalToSuperview().offset(20)
                    make.left.equalToSuperview().offset(12.5)
                } else {
                    make.top.equalToSuperview().offset(45)
                    make.left.equalToSuperview().offset(20)
                }
                make.size.equalTo(40)
            }
        }
    }

    private func setupSocialLoginElements() {
        fbLoginBtn.backgroundColor = .fbBlue()
        fbLoginBtn.layer.cornerRadius = GlobalCornerRadius.value
        fbLoginBtn.setTitleColor(.white, for: .normal)
        
        googleLoginBtn.alpha = 0
        googleLoginBtn.backgroundColor = .white
        googleLoginBtn.layer.cornerRadius = GlobalCornerRadius.value
        googleLoginBtn.setTitleColor(.darkGrayText(), for: .normal)
        
        //apple sign in
        if #available(iOS 13.0, *) {
            if let appleSignInBtn = appleSignInBtn as! ASAuthorizationAppleIDButton? {
                appleSignInBtn.cornerRadius = GlobalCornerRadius.value
                appleSignInBtn.addTarget(self, action: #selector(appleSignInBtnTapped), for: .touchUpInside)
                addSubview(appleSignInBtn)
                appleSignInBtn.snp.makeConstraints { (make) in
                    make.bottom.equalTo(fbLoginBtn.snp.top).offset(-20)
                    make.height.equalTo(46)
                    make.left.equalToSuperview().offset(40)
                    make.right.equalToSuperview().offset(-40)
                }
            }
        }
        
        emailLoginLabel.textColor = .whiteText()
        
        //create blur effect for register button
        let blurView = VisualEffectView.create()
        
        regBtn.layer.cornerRadius = GlobalCornerRadius.value
        regBtn.backgroundColor = .clear
        regBtn.clipsToBounds = true
        regBtn.setTitleColor(.white, for: .normal)
        regBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        regBtn.insertSubview(blurView, belowSubview: regBtn.titleLabel!)
        blurView.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(regBtn.snp.center)
            make.width.equalTo(UIScreen.main.bounds.size.width - 80)
            make.height.equalTo(regBtn.bounds.height)
        }
        
        if UIDevice.current.type == .iPhone_5_5S_5C_SE{ //lowering this constant on iPhone SE
            regPwRefillTextFieldBottomConstraint.constant = 45
            layoutIfNeeded()
        }
    }
    
    @objc func appleSignInBtnTapped() {
        delegate?.didTapAppleSignIn()
    }
    
    private func setupEmailLoginElements() {
        //create blur effect for emailTextFieldBg
        let blurView = VisualEffectView.create()
        
        emailTextFieldBg.layer.cornerRadius = GlobalCornerRadius.value
        emailTextFieldBg.backgroundColor = .clear
        emailTextFieldBg.insertSubview(blurView, at: 0)
        
        blurView.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(emailTextFieldBg.snp.center)
            make.width.equalTo(UIScreen.main.bounds.size.width - 80)
            make.height.equalTo(emailTextFieldBg.bounds.height)
        }
        
        emailTextField.delegate = self
        emailTextField.returnKeyType = .next
        emailTextField.autocorrectionType = .no
        emailTextField.placeholder = "Email"
        emailTextField.placeholderFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        emailTextField.placeholderColor = .white15Alpha()
        emailTextField.title = "Email"
        emailTextField.titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        emailTextField.titleColor = .whiteText75Alpha()
        emailTextField.selectedTitleColor = .whiteText()
        emailTextField.titleFormatter = { $0 } //disable title uppercase
        emailTextField.textColor = .whiteText80Alpha()
        emailTextField.lineHeight = 1.25
        emailTextField.lineColor = .white15Alpha()
        emailTextField.selectedLineHeight = 1.5
        emailTextField.selectedLineColor = .white50Alpha()
        
        //create blur effect for pwTextFieldBg
        let blurView2 = VisualEffectView.create()
        
        pwTextFieldBg.layer.cornerRadius = GlobalCornerRadius.value
        pwTextFieldBg.backgroundColor = .clear
        pwTextFieldBg.insertSubview(blurView2, at: 0)
        
        blurView2.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(pwTextFieldBg.snp.center)
            make.width.equalTo(UIScreen.main.bounds.size.width - 80)
            make.height.equalTo(pwTextFieldBg.bounds.height)
        }
        
        pwTextField.delegate = self
        pwTextField.returnKeyType = .go
        pwTextField.isSecureTextEntry = true
        pwTextField.placeholder = "Password"
        pwTextField.placeholderFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        pwTextField.placeholderColor = .white15Alpha()
        pwTextField.title = "Password"
        pwTextField.titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        pwTextField.titleColor = .whiteText75Alpha()
        pwTextField.selectedTitleColor = .lightPurple()
        pwTextField.titleFormatter = { $0 } //disable title uppercase
        pwTextField.textColor = .whiteText80Alpha()
        pwTextField.lineHeight = 1.25
        pwTextField.lineColor = .white15Alpha()
        pwTextField.selectedLineHeight = 1.5
        pwTextField.selectedLineColor = .white50Alpha()
        
        //activity indicatior
        loginActivityIndicator.type = .lineScale
        loginActivityIndicator.alpha = 0
        loginActionBtn.addSubview(loginActivityIndicator)
        loginActivityIndicator.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
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
        loginActionBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        loginActionBtn.insertSubview(loginActionBtnGradientBg, at: 0)
        loginActionBtnGradientBg.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(loginActionBtn.snp.center)
            make.width.equalTo(loginActionBtn.snp.width)
            make.height.equalTo(loginActionBtn.bounds.height)
        }
        
        for view in emailLoginElements { //these views will be shown later
            view.alpha = 0
            view.isUserInteractionEnabled = false
        }
    }
    
    private func setupRegisterElements() {
        //create blur effect for regEmailTextFieldBg
        let blurView = VisualEffectView.create()
        
        regEmailTextFieldBg.layer.cornerRadius = GlobalCornerRadius.value
        regEmailTextFieldBg.backgroundColor = .clear
        regEmailTextFieldBg.insertSubview(blurView, at: 0)
        
        blurView.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(regEmailTextFieldBg.snp.center)
            make.width.equalTo(UIScreen.main.bounds.size.width - 80)
            make.height.equalTo(regEmailTextFieldBg.bounds.height)
        }
        
        regEmailTextField.delegate = self
        regEmailTextField.returnKeyType = .next
        regEmailTextField.autocorrectionType = .no
        regEmailTextField.placeholder = "Email"
        regEmailTextField.placeholderFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        regEmailTextField.placeholderColor = .white15Alpha()
        regEmailTextField.title = "Email"
        regEmailTextField.titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        regEmailTextField.titleColor = .whiteText75Alpha()
        regEmailTextField.selectedTitleColor = .lightPurple()
        regEmailTextField.titleFormatter = { $0 } //disable title uppercase
        regEmailTextField.textColor = .whiteText80Alpha()
        regEmailTextField.lineHeight = 1.25
        regEmailTextField.lineColor = .white15Alpha()
        regEmailTextField.selectedLineHeight = 1.5
        regEmailTextField.selectedLineColor = .white50Alpha()
        
        //create blur effect for regPwTextFieldBg
        let blurView2 = VisualEffectView.create()
        
        regPwTextFieldBg.layer.cornerRadius = GlobalCornerRadius.value
        regPwTextFieldBg.backgroundColor = .clear
        regPwTextFieldBg.insertSubview(blurView2, at: 0)
        
        blurView2.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(regPwTextFieldBg.snp.center)
            make.width.equalTo(UIScreen.main.bounds.size.width - 80)
            make.height.equalTo(regPwTextFieldBg.bounds.height)
        }
        
        regPwTextField.delegate = self
        regPwTextField.returnKeyType = .next
        regPwTextField.isSecureTextEntry = true
        regPwTextField.placeholder = "Password"
        regPwTextField.placeholderFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        regPwTextField.placeholderColor = .white15Alpha()
        regPwTextField.title = "Password"
        regPwTextField.titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        regPwTextField.titleColor = .whiteText75Alpha()
        regPwTextField.selectedTitleColor = .lightPurple()
        regPwTextField.titleFormatter = { $0 } //disable title uppercase
        regPwTextField.textColor = .whiteText80Alpha()
        regPwTextField.lineHeight = 1.25
        regPwTextField.lineColor = .white15Alpha()
        regPwTextField.selectedLineHeight = 1.5
        regPwTextField.selectedLineColor = .white50Alpha()
        
        //create blur effect for regPwRefillTextFieldBg
        let blurView3 = VisualEffectView.create()
        
        regPwRefillTextFieldBg.layer.cornerRadius = GlobalCornerRadius.value
        regPwRefillTextFieldBg.backgroundColor = .clear
        regPwRefillTextFieldBg.insertSubview(blurView3, at: 0)
        
        blurView3.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(regPwRefillTextFieldBg.snp.center)
            make.width.equalTo(UIScreen.main.bounds.size.width - 80)
            make.height.equalTo(regPwRefillTextFieldBg.bounds.height)
        }
        
        regPwRefillTextField.delegate = self
        regPwRefillTextField.returnKeyType = .go
        regPwRefillTextField.isSecureTextEntry = true
        regPwRefillTextField.placeholder = "Confirm Password"
        regPwRefillTextField.placeholderFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        regPwRefillTextField.placeholderColor = .white15Alpha()
        regPwRefillTextField.title = "Confirm Password"
        regPwRefillTextField.titleFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        regPwRefillTextField.titleColor = .whiteText75Alpha()
        regPwRefillTextField.selectedTitleColor = .lightPurple()
        regPwRefillTextField.titleFormatter = { $0 } //disable title uppercase
        regPwRefillTextField.textColor = .whiteText80Alpha()
        regPwRefillTextField.lineHeight = 1.25
        regPwRefillTextField.lineColor = .white15Alpha()
        regPwRefillTextField.selectedLineHeight = 1.5
        regPwRefillTextField.selectedLineColor = .white50Alpha()
        
        //activity indicatior
        regActivityIndicator.type = .lineScale
        regActivityIndicator.alpha = 0
        regActionBtn.addSubview(regActivityIndicator)
        regActivityIndicator.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        //gradient for registerBtn
        regActionBtnGradientBg.startPastelPoint = .topLeft
        regActionBtnGradientBg.endPastelPoint = .bottomRight
        regActionBtnGradientBg.animationDuration = 3
        regActionBtnGradientBg.isUserInteractionEnabled = false
        regActionBtnGradientBg.setColors([
            UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
            UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
            UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
            UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0),
            UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0)])
        
        regActionBtn.layer.cornerRadius = GlobalCornerRadius.value
        regActionBtn.backgroundColor = .clear
        regActionBtn.clipsToBounds = true
        regActionBtn.setTitleColor(.white, for: .normal)
        regActionBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        regActionBtn.insertSubview(regActionBtnGradientBg, at: 0)
        regActionBtnGradientBg.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(regBtn.snp.center)
            make.width.equalTo(regBtn.snp.width)
            make.height.equalTo(regBtn.bounds.height)
        }
        
        for view in registerElements { //these views will be shown later
            view.alpha = 0
            view.isUserInteractionEnabled = false
        }
    }

    
    @objc func didTapDismissBtn(_ sender: Any) {
        delegate?.didTapDismissBtn()
    }
    
    @IBAction func didTapFbLogin(_ sender: Any) {
        delegate?.didTapFbLogin()
    }
    
    @IBAction func didTapGoogleLogin(_ sender: Any) {
        //delegate?.didTapGoogleLogin()
    }
    
    @IBAction func didTapRegisterBtn(_ sender: UIButton) {
        delegate?.didTapRegisterBtn()
    }
    
    @IBAction func didTapEmailLogin(_ sender: Any) {
        delegate?.didTapEmailLogin()
    }
    
    @IBAction func didTapLoginAction(_ sender: Any) {
        delegate?.didTapLoginAction()
    }
    
    @IBAction func didTapRegAction(_ sender: Any) {
        delegate?.didTapRegAction()
    }
    
    @objc func keyboardWillAppear(_ notification: Notification) {
        //Get keyboard height
        if !isKeyboardPresent {
            print("keyboard will appear")
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardMinY = keyboardRectangle.minY
                var keyboardTopPlusPadding = self.loginActionBtn.frame.minY - keyboardMinY
                if #available(iOS 13.0, *) {
                    keyboardTopPlusPadding += 80
                } else {
                    keyboardTopPlusPadding += 40
                }
                
                //animate the constraint's constant change
                UIView.animate(withDuration: 0.3) {
                    self.pwTextFieldBgBottomConstraint.constant = keyboardTopPlusPadding
                    self.regPwRefillTextFieldBottomConstraint.constant = keyboardTopPlusPadding
                    
                    if UIDevice.current.type == .iPhone_5_5S_5C_SE && self.regEmailTextFieldBg.alpha != 0 { //hide descLabel on iPhone SE
                        self.descLabel.alpha = 0
                    }
                    
                    self.layoutIfNeeded()
                }
            }
            isKeyboardPresent = true
        }
    }
    
    @objc func keyboardWillDisappear() {
        if isKeyboardPresent {
            print("keyboard hidden")
            UIView.animate(withDuration: 0.3) {
                if UIDevice.current.type == .iPhone_5_5S_5C_SE { //show descLabel on iPhone SE
                    self.descLabel.alpha = 1
                    self.regPwRefillTextFieldBottomConstraint.constant = 45
                } else {
                    self.regPwRefillTextFieldBottomConstraint.constant = 75
                }
                self.pwTextFieldBgBottomConstraint.constant = 75 //default is 75
                self.layoutIfNeeded()
            }
            isKeyboardPresent = false
        }
    }
    
}

//MARK: - UITextfield delegate
extension LoginView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        //email login section
        case emailTextField:
            pwTextField.becomeFirstResponder()
        case pwTextField:
            pwTextField.resignFirstResponder()
            delegate?.didTapLoginAction()
            
        //register section
        case regEmailTextField:
            regPwTextField.becomeFirstResponder()
        case regPwTextField:
            regPwRefillTextField.becomeFirstResponder()
        case regPwRefillTextField:
            regPwRefillTextField.resignFirstResponder()
            delegate?.didTapRegAction()
            
        default:
            textField.resignFirstResponder()
        }
        return false
    }
}
