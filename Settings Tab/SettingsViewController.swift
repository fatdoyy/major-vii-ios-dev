//
//  SettingsViewController.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let screenWidth = UIScreen.main.bounds.width
    
    var mainScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var buskerNameLabel: UILabel!
    var accountTypeLabel: UILabel!
    var profileBtn: UIButton!
    var buskerIcon: UIImageView!
    
    @IBOutlet weak var logInOrOutBtn: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray()
        //contentView.backgroundColor = .darkGray()
        
//        logInOrOutBtn.isHidden = true
//        if UserService.User.isLoggedIn() {
//            logInOrOutBtn.setTitle("Log Out", for: .normal)
//        } else {
//            logInOrOutBtn.setTitle("Log In", for: .normal)
//        }
//
        mainScrollView = UIScrollView()
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.contentInsetAdjustmentBehavior = .never
        //mainScrollView.delegate = self
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.backgroundColor = .darkGray()
        view.addSubview(mainScrollView)
        mainScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }

        
        setupHeaderSection()
        setupGeneralSection()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
        
        if let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView {
            statusBar.backgroundColor = .darkGray()
        } else {
            print("Can't get status bar?")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainScrollView.contentSize = CGSize(width: screenWidth, height: UIScreen.main.bounds.height + 1100)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupNavBar() {
        navigationItem.title = ""
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray()]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    @IBAction func didTapLogInOrOutBtn(_ sender: Any) {
        if logInOrOutBtn.title(for: .normal) == "Log In" {
            let loginVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            self.present(loginVC, animated: true, completion: nil)
            logInOrOutBtn.setTitle("Log Out", for: .normal)
        } else {
            UserService.User.logOut(fromVC: self)
            logInOrOutBtn.setTitle("Log In", for: .normal)
        }
    }
}

//MARK: Header Section
extension SettingsViewController {
    private func setupHeaderSection() {
        if UserService.User.isLoggedIn() {
            buskerNameLabel = UILabel()
            buskerNameLabel.textColor = .white
            buskerNameLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
            buskerNameLabel.text = "Hello, \(UserDefaults.standard.string(forKey: LOCAL_KEY.USERNAME) ?? "")!"
            mainScrollView.addSubview(buskerNameLabel)
            buskerNameLabel.snp.makeConstraints { (make) in
                //make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-42)
                make.top.equalToSuperview().offset(98)

                switch UIDevice.current.type { //This is a very dumb method... please replace this if there are better soultions...
                case .iPhone_5_5S_5C_SE, .iPhone_6_6S_7_8, .iPhone_X_Xs:
                    make.left.equalToSuperview().offset(17)
                    make.width.equalTo(screenWidth - 37)
                case .iPhone_6_6S_7_8_PLUS, .iPhone_Xr, .iPhone_Xs_Max:
                    make.left.equalToSuperview().offset(21)
                    make.width.equalTo(screenWidth - 41)
                default: print("cannot create buskerNameLabel")
                }
            }
            
            accountTypeLabel = UILabel()
            accountTypeLabel.textColor = .purpleText()
            accountTypeLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            accountTypeLabel.text = "(Busker)"
            mainScrollView.addSubview(accountTypeLabel)
            accountTypeLabel.snp.makeConstraints { (make) in
                make.top.equalTo(buskerNameLabel.snp.bottom)
                make.left.equalTo(buskerNameLabel.snp.left)
            }
            
            profileBtn = UIButton()
            profileBtn.setTitle("View Profile", for: .normal)
            profileBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            profileBtn.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            profileBtn.layer.cornerRadius = 3
            profileBtn.addTarget(self, action: #selector(profileBtnTapped), for: .touchUpInside)
            mainScrollView.addSubview(profileBtn)
            profileBtn.snp.makeConstraints { (make) in
                make.top.equalTo(accountTypeLabel.snp.bottom).offset(10)
                make.width.equalTo(100)
                make.height.equalTo(28)
                make.left.equalTo(accountTypeLabel.snp.left)
            }
            
            buskerIcon = UIImageView()
            buskerIcon.layer.cornerRadius = 48
            buskerIcon.backgroundColor = .darkGray
            //buskerIcon.kf.setImage(with: url)
            mainScrollView.addSubview(buskerIcon)
            buskerIcon.snp.makeConstraints { (make) in
                make.top.equalTo(buskerNameLabel.snp.top)
                make.size.equalTo(96)
                make.right.equalTo(buskerNameLabel.snp.right)
            }
            
            
        } else {
            //create login view, height 96
        }
    }
    
    @objc func profileBtnTapped() {
        print("profile btn tapped")
    }
}

//MARK: General Settings Section
extension SettingsViewController {
    private func setupGeneralSection() {
        let generalSettingsLabel = UILabel()
        generalSettingsLabel.text = "General Settings"
        generalSettingsLabel.textColor = .white
        generalSettingsLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        mainScrollView.addSubview(generalSettingsLabel)
        generalSettingsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profileBtn.snp.bottom).offset(44)
            make.left.equalTo(buskerNameLabel)
        }
        
        let generalSettingsDescLabel = UILabel()
        generalSettingsDescLabel.text = "Configure your personal settings"
        generalSettingsDescLabel.textColor = .white
        generalSettingsDescLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        mainScrollView.addSubview(generalSettingsDescLabel)
        generalSettingsDescLabel.snp.makeConstraints { (make) in
            make.top.equalTo(generalSettingsLabel.snp.bottom).offset(4)
            make.left.equalTo(buskerNameLabel)
        }
        
        let generalSectionBg = UIView()
        generalSectionBg.backgroundColor = .darkGray()
        generalSectionBg.clipsToBounds = true
        generalSectionBg.layer.cornerRadius = GlobalCornerRadius.value
        mainScrollView.addSubview(generalSectionBg)
        generalSectionBg.snp.makeConstraints { (make) in
            make.height.equalTo(64 * 3)
            make.width.equalTo(screenWidth - 40)
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(generalSettingsDescLabel.snp.bottom).offset(15)
        }
        
        let notificationsBtn = UIButton()
        notificationsBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        notificationsBtn.contentHorizontalAlignment = .left
        notificationsBtn.setTitle("Notifications", for: .normal)
        notificationsBtn.setTitleColor(.white, for: .normal)
        notificationsBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        notificationsBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        generalSectionBg.addSubview(notificationsBtn)
        notificationsBtn.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.width.equalToSuperview()
            make.top.left.equalToSuperview()
        }
        
        let notificationIcon = UIImageView()
        notificationIcon.image = UIImage(named: "icon_apple_wallet")
        generalSectionBg.addSubview(notificationIcon)
        notificationIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(notificationsBtn)
            make.size.equalTo(24)
            make.right.equalTo(-20)
        }
        
        let sepLine = UIView()
        sepLine.backgroundColor = .darkGray
        sepLine.layer.cornerRadius = 0.5
        generalSectionBg.addSubview(sepLine)
        sepLine.snp.makeConstraints { (make) in
            make.top.equalTo(notificationsBtn.snp.bottom).offset(-1)
            make.left.equalTo(generalSectionBg.snp.left).offset(20)
            make.width.equalTo(screenWidth - 80)
            make.height.equalTo(2)
        }
        
        let buskerRegBtn = UIButton()
        buskerRegBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        buskerRegBtn.contentHorizontalAlignment = .left
        buskerRegBtn.setTitle("Become a MajorVII performer!", for: .normal)
        buskerRegBtn.setTitleColor(.white, for: .normal)
        buskerRegBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        buskerRegBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        generalSectionBg.addSubview(buskerRegBtn)
        buskerRegBtn.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.width.equalToSuperview()
            make.top.equalTo(notificationsBtn.snp.bottom)
        }
        
        let buskerRegIcon = UIImageView()
        buskerRegIcon.image = UIImage(named: "icon_confused")
        generalSectionBg.addSubview(buskerRegIcon)
        buskerRegIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(buskerRegBtn)
            make.size.equalTo(24)
            make.right.equalTo(-20)
        }
        
        let sepLine2 = UIView()
        sepLine2.backgroundColor = .darkGray
        sepLine2.layer.cornerRadius = 0.5
        generalSectionBg.addSubview(sepLine2)
        sepLine2.snp.makeConstraints { (make) in
            make.top.equalTo(buskerRegBtn.snp.bottom).offset(-1)
            make.left.equalTo(generalSectionBg.snp.left).offset(20)
            make.width.equalTo(screenWidth - 80)
            make.height.equalTo(2)
        }
        
        let settingsBtn = UIButton()
        settingsBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        settingsBtn.contentHorizontalAlignment = .left
        settingsBtn.setTitle("Settings", for: .normal)
        settingsBtn.setTitleColor(.white, for: .normal)
        settingsBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        settingsBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        generalSectionBg.addSubview(settingsBtn)
        settingsBtn.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.width.equalToSuperview()
            make.top.equalTo(buskerRegBtn.snp.bottom)
        }
        
        let settingsIcon = UIImageView()
        settingsIcon.image = UIImage(named: "icon_google")
        generalSectionBg.addSubview(settingsIcon)
        settingsIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(settingsBtn)
            make.size.equalTo(24)
            make.right.equalTo(-20)
        }
    }
}
