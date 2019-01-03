//
//  LoginView.swift
//  major-7-ios
//
//  Created by jason on 3/1/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

protocol LoginViewDelegate{
    func fbLoginPressed()
}

class LoginView: UIView {
    
    var delegate: LoginViewDelegate?
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var fbLoginBtn: UIButton!
    @IBOutlet weak var googleLoginBtn: UIButton!
    
    @IBOutlet weak var emailLoginLabel: UILabel!
    
    @IBOutlet weak var emailLoginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var guestLoginBtn: UIButton!
    
    @IBOutlet weak var tcLabel: UILabel!
    
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
        
        logo.backgroundColor = .lightGray
        
        descLabel.textColor = .whiteText()
        emailLoginLabel.textColor = .whiteText()
        
        tcLabel.textColor = .whiteText50Alpha()
    }
    @IBAction func fbLoginPressed(_ sender: Any) {
        delegate?.fbLoginPressed()

    }
    
//    @objc func loginButtonClicked() {
//        delegate?.fbLoginPressed()
//    }
}
