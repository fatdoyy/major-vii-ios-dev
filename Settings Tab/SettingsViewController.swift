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
    
    //Header
    var buskerNameLabel: UILabel!
    var accountTypeLabel: UILabel!
    var logoutBtn: UIButton!
    var buskerIcon: UIImageView!
    
    //Genereal Section
    var generalSectionTitle: UILabel!
    var generalSettingsDesc: UILabel!
    var generalSectionBg: UIView!
    var generalSectionNotiBtn: UIButton!
    var generalSectionNotiIcon: UIImageView!
    var generalSectionSepLine: UIView!
    var generalSectionBuskerRegBtn: UIButton!
    var generalSectionRegIcon: UIImageView!
    var generalSectionSepLine2: UIView!
    var generalSectionSettingsBtn: UIButton!
    var generalSectionSettingsIcon: UIImageView!
    
    //Busker Section
    var buskerSectionTitle: UILabel!
    var buskerSectionDesc: UILabel!
    var buskerSectionBg: UIView!
    var buskerSectionProfileBtn: UIButton!
    var buskerSectionProfileIcon: UIImageView!
    var buskerSectionSepLine: UIView!
    var buskerSectionEventBtn: UIButton!
    var buskerSectionEventIcon: UIImageView!
    var buskerSectionSepLine2: UIView!
    var buskerSectionPostBtn: UIButton!
    var buskerSectionPostIcon: UIImageView!
    
    //Others Section
    var othersSectionTitle: UILabel!
    var othersSectionDesc: UILabel!
    var othersSectionBg: UIView!
    var othersSectionTermsBtn: UIButton!
    var othersSectionTermsIcon: UIImageView!
    var othersSectionSepLine: UIView!
    var othersSectionPrivacyBtn: UIButton!
    var othersSectionPrivacyIcon: UIImageView!
    var othersSectionSepLine2: UIView!
    var othersSectionFeedbackBtn: UIButton!
    var othersSectionFeedbackIcon: UIImageView!
    var othersSectionSepLine3: UIView!
    var othersSectionRateBtn: UIButton!
    var othersSectionRateIcon: UIImageView!
    var othersSectionSepLine4: UIView!
    var othersSectionAboutBtn: UIButton!
    var othersSectionAboutIcon: UIImageView!
    
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
        mainScrollView.contentInset = UIEdgeInsets.zero
        //mainScrollView.delegate = self
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.backgroundColor = .darkGray()
        view.addSubview(mainScrollView)
        mainScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }

        setupHeaderSection()
        setupGeneralSection()
        setupBuskerSection()
        setupOthersSection()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView {
            statusBar.backgroundColor = .clear
        } else {
            print("Can't get status bar?")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainScrollView.contentSize = CGSize(width: screenWidth, height: UIScreen.main.bounds.height + 500)
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
                make.left.equalToSuperview().offset(20)
                make.width.equalTo(screenWidth - 40)
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
            
            logoutBtn = UIButton()
            logoutBtn.setTitle("Logout", for: .normal)
            logoutBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            logoutBtn.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            logoutBtn.layer.cornerRadius = 3
            logoutBtn.addTarget(self, action: #selector(logoutBtnTapped), for: .touchUpInside)
            mainScrollView.addSubview(logoutBtn)
            logoutBtn.snp.makeConstraints { (make) in
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
    
    
    @objc func logoutBtnTapped(_ sender: Any) {
        if logoutBtn.title(for: .normal) == "Login" {
            let loginVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            self.present(loginVC, animated: true, completion: nil)
            logoutBtn.setTitle("Logout", for: .normal)
        } else {
            UserService.User.logOut(fromVC: self)
            logoutBtn.setTitle("Login", for: .normal)
        }
    }
}

//MARK: General Settings Section
extension SettingsViewController {
    private func setupGeneralSection() {
        generalSectionTitle = UILabel()
        generalSectionTitle.text = "General Settings"
        generalSectionTitle.textColor = .white
        generalSectionTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        mainScrollView.addSubview(generalSectionTitle)
        let generalSectionTitleHeight = 21
        generalSectionTitle.snp.makeConstraints { (make) in
            make.top.equalTo(logoutBtn.snp.bottom).offset(44)
            make.left.equalTo(buskerNameLabel)
            make.height.equalTo(generalSectionTitleHeight)
        }
        print("settings title height: \(generalSectionTitle.bounds.height)")
        
        generalSettingsDesc = UILabel()
        generalSettingsDesc.text = "Configure your personal settings"
        generalSettingsDesc.textColor = .white
        generalSettingsDesc.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        mainScrollView.addSubview(generalSettingsDesc)
        let generalSettingsDescHeight = 14
        generalSettingsDesc.snp.makeConstraints { (make) in
            make.top.equalTo(generalSectionTitle.snp.bottom).offset(4)
            make.left.equalTo(buskerNameLabel)
            make.height.equalTo(generalSettingsDescHeight)
        }
        
        generalSectionBg = UIView()
        generalSectionBg.backgroundColor = .darkGray()
        generalSectionBg.clipsToBounds = true
        generalSectionBg.layer.cornerRadius = GlobalCornerRadius.value
        mainScrollView.addSubview(generalSectionBg)
        let generalSectionBgHeight = 64 * 3
        generalSectionBg.snp.makeConstraints { (make) in
            make.height.equalTo(generalSectionBgHeight)
            make.width.equalTo(screenWidth - 40)
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(generalSettingsDesc.snp.bottom).offset(15)
        }
        
        generalSectionNotiBtn = UIButton()
        generalSectionNotiBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        generalSectionNotiBtn.contentHorizontalAlignment = .left
        generalSectionNotiBtn.setTitle("Notifications", for: .normal)
        generalSectionNotiBtn.setTitleColor(.white, for: .normal)
        generalSectionNotiBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        generalSectionNotiBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        generalSectionBg.addSubview(generalSectionNotiBtn)
        generalSectionNotiBtn.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.width.equalToSuperview()
            make.top.left.equalToSuperview()
        }
        
        generalSectionNotiIcon = UIImageView()
        generalSectionNotiIcon.image = UIImage(named: "icon_apple_wallet")
        generalSectionBg.addSubview(generalSectionNotiIcon)
        generalSectionNotiIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(generalSectionNotiBtn)
            make.size.equalTo(24)
            make.right.equalTo(-20)
        }
        
        generalSectionSepLine = UIView()
        generalSectionSepLine.backgroundColor = .darkGray
        generalSectionSepLine.layer.cornerRadius = 0.5
        generalSectionBg.addSubview(generalSectionSepLine)
        generalSectionSepLine.snp.makeConstraints { (make) in
            make.top.equalTo(generalSectionNotiBtn.snp.bottom).offset(-1)
            make.left.equalTo(generalSectionBg.snp.left).offset(20)
            make.width.equalTo(screenWidth - 80)
            make.height.equalTo(2)
        }
        
        generalSectionBuskerRegBtn = UIButton()
        generalSectionBuskerRegBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        generalSectionBuskerRegBtn.contentHorizontalAlignment = .left
        generalSectionBuskerRegBtn.setTitle("Become a MajorVII performer!", for: .normal)
        generalSectionBuskerRegBtn.setTitleColor(.white, for: .normal)
        generalSectionBuskerRegBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        generalSectionBuskerRegBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        generalSectionBg.addSubview(generalSectionBuskerRegBtn)
        generalSectionBuskerRegBtn.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.width.equalToSuperview()
            make.top.equalTo(generalSectionNotiBtn.snp.bottom)
            make.left.equalToSuperview()
        }
        
        generalSectionRegIcon = UIImageView()
        generalSectionRegIcon.image = UIImage(named: "icon_confused")
        generalSectionBg.addSubview(generalSectionRegIcon)
        generalSectionRegIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(generalSectionBuskerRegBtn)
            make.size.equalTo(24)
            make.right.equalTo(-20)
        }
        
        generalSectionSepLine2 = UIView()
        generalSectionSepLine2.backgroundColor = .darkGray
        generalSectionSepLine2.layer.cornerRadius = 0.5
        generalSectionBg.addSubview(generalSectionSepLine2)
        generalSectionSepLine2.snp.makeConstraints { (make) in
            make.top.equalTo(generalSectionBuskerRegBtn.snp.bottom).offset(-1)
            make.left.equalTo(generalSectionBg.snp.left).offset(20)
            make.width.equalTo(screenWidth - 80)
            make.height.equalTo(2)
        }
        
        generalSectionSettingsBtn = UIButton()
        generalSectionSettingsBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        generalSectionSettingsBtn.contentHorizontalAlignment = .left
        generalSectionSettingsBtn.setTitle("Settings", for: .normal)
        generalSectionSettingsBtn.setTitleColor(.white, for: .normal)
        generalSectionSettingsBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        generalSectionSettingsBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        generalSectionBg.addSubview(generalSectionSettingsBtn)
        generalSectionSettingsBtn.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.width.equalToSuperview()
            make.top.equalTo(generalSectionBuskerRegBtn.snp.bottom)
            make.left.equalToSuperview()
        }
        
        generalSectionSettingsIcon = UIImageView()
        generalSectionSettingsIcon.image = UIImage(named: "icon_google")
        generalSectionBg.addSubview(generalSectionSettingsIcon)
        generalSectionSettingsIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(generalSectionSettingsBtn)
            make.size.equalTo(24)
            make.right.equalTo(-20)
        }
    }
}

//MARK: Busker/Finder Section
extension SettingsViewController {
    private func setupBuskerSection() {
        buskerSectionTitle = UILabel()
        buskerSectionTitle.text = "Account Details"
        buskerSectionTitle.textColor = .white
        buskerSectionTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        mainScrollView.addSubview(buskerSectionTitle)
        let buskerSectionTitleHeight = 21
        buskerSectionTitle.snp.makeConstraints { (make) in
            make.top.equalTo(generalSectionBg.snp.bottom).offset(30)
            make.left.equalTo(buskerNameLabel)
            make.height.equalTo(buskerSectionTitleHeight)
        }
        
        buskerSectionDesc = UILabel()
        buskerSectionDesc.text = "View or edit your Major VII account details"
        buskerSectionDesc.textColor = .white
        buskerSectionDesc.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        mainScrollView.addSubview(buskerSectionDesc)
        let buskerSectionDescHeight = 14
        buskerSectionDesc.snp.makeConstraints { (make) in
            make.top.equalTo(buskerSectionTitle.snp.bottom).offset(4)
            make.left.equalTo(buskerNameLabel)
            make.height.equalTo(buskerSectionDescHeight)
        }
        
        buskerSectionBg = UIView()
        buskerSectionBg.backgroundColor = .darkGray()
        buskerSectionBg.clipsToBounds = true
        buskerSectionBg.layer.cornerRadius = GlobalCornerRadius.value
        mainScrollView.addSubview(buskerSectionBg)
        let generalSectionBgHeight = 64 * 3 //depends on how many row
        buskerSectionBg.snp.makeConstraints { (make) in
            make.height.equalTo(generalSectionBgHeight)
            make.width.equalTo(screenWidth - 40)
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(buskerSectionDesc.snp.bottom).offset(15)
        }
        
        buskerSectionProfileBtn = UIButton()
        buskerSectionProfileBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        buskerSectionProfileBtn.contentHorizontalAlignment = .left
        buskerSectionProfileBtn.setTitle("Edit your profile", for: .normal)
        buskerSectionProfileBtn.setTitleColor(.white, for: .normal)
        buskerSectionProfileBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        buskerSectionProfileBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        buskerSectionBg.addSubview(buskerSectionProfileBtn)
        buskerSectionProfileBtn.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.width.equalToSuperview()
            make.top.left.equalToSuperview()
        }
        
        buskerSectionProfileIcon = UIImageView()
        buskerSectionProfileIcon.image = UIImage(named: "icon_apple_wallet")
        buskerSectionBg.addSubview(buskerSectionProfileIcon)
        buskerSectionProfileIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(buskerSectionProfileBtn)
            make.size.equalTo(24)
            make.right.equalTo(-20)
        }
        
        buskerSectionSepLine = UIView()
        buskerSectionSepLine.backgroundColor = .darkGray
        buskerSectionSepLine.layer.cornerRadius = 0.5
        buskerSectionBg.addSubview(buskerSectionSepLine)
        buskerSectionSepLine.snp.makeConstraints { (make) in
            make.top.equalTo(buskerSectionProfileBtn.snp.bottom).offset(-1)
            make.left.equalTo(buskerSectionBg.snp.left).offset(20)
            make.width.equalTo(screenWidth - 80)
            make.height.equalTo(2)
        }
        
        buskerSectionEventBtn = UIButton()
        buskerSectionEventBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        buskerSectionEventBtn.contentHorizontalAlignment = .left
        buskerSectionEventBtn.setTitle("Edit your events?", for: .normal)
        buskerSectionEventBtn.setTitleColor(.white, for: .normal)
        buskerSectionEventBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        buskerSectionEventBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        buskerSectionBg.addSubview(buskerSectionEventBtn)
        buskerSectionEventBtn.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.width.equalToSuperview()
            make.top.equalTo(buskerSectionProfileBtn.snp.bottom)
            make.left.equalToSuperview()
        }
        
        buskerSectionEventIcon = UIImageView()
        buskerSectionEventIcon.image = UIImage(named: "icon_confused")
        buskerSectionBg.addSubview(buskerSectionEventIcon)
        buskerSectionEventIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(buskerSectionEventBtn)
            make.size.equalTo(24)
            make.right.equalTo(-20)
        }
        
        buskerSectionSepLine2 = UIView()
        buskerSectionSepLine2.backgroundColor = .darkGray
        buskerSectionSepLine2.layer.cornerRadius = 0.5
        buskerSectionBg.addSubview(buskerSectionSepLine2)
        buskerSectionSepLine2.snp.makeConstraints { (make) in
            make.top.equalTo(buskerSectionEventBtn.snp.bottom).offset(-1)
            make.left.equalTo(buskerSectionBg.snp.left).offset(20)
            make.width.equalTo(screenWidth - 80)
            make.height.equalTo(2)
        }
        
        buskerSectionPostBtn = UIButton()
        buskerSectionPostBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        buskerSectionPostBtn.contentHorizontalAlignment = .left
        buskerSectionPostBtn.setTitle("Edit your posts", for: .normal)
        buskerSectionPostBtn.setTitleColor(.white, for: .normal)
        buskerSectionPostBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        buskerSectionPostBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        buskerSectionBg.addSubview(buskerSectionPostBtn)
        buskerSectionPostBtn.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.width.equalToSuperview()
            make.top.equalTo(buskerSectionEventBtn.snp.bottom)
            make.left.equalToSuperview()
        }
        
        buskerSectionPostIcon = UIImageView()
        buskerSectionPostIcon.image = UIImage(named: "icon_google")
        buskerSectionBg.addSubview(buskerSectionPostIcon)
        buskerSectionPostIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(buskerSectionPostBtn)
            make.size.equalTo(24)
            make.right.equalTo(-20)
        }
    }
}

//MARK: Other Section
extension SettingsViewController {
    private func setupOthersSection() {
        othersSectionTitle = UILabel()
        othersSectionTitle.text = "Others"
        othersSectionTitle.textColor = .white
        othersSectionTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        mainScrollView.addSubview(othersSectionTitle)
        let othersSectionTitleHeight = 21
        othersSectionTitle.snp.makeConstraints { (make) in
            make.top.equalTo(buskerSectionBg.snp.bottom).offset(30)
            make.left.equalTo(buskerNameLabel)
            make.height.equalTo(othersSectionTitleHeight)
        }
        
        othersSectionDesc = UILabel()
        othersSectionDesc.text = "Configure other settings"
        othersSectionDesc.textColor = .white
        othersSectionDesc.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        mainScrollView.addSubview(othersSectionDesc)
        let othersSectionDescHeight = 14
        othersSectionDesc.snp.makeConstraints { (make) in
            make.top.equalTo(othersSectionTitle.snp.bottom).offset(4)
            make.left.equalTo(buskerNameLabel)
            make.height.equalTo(othersSectionDescHeight)
        }
        
        othersSectionBg = UIView()
        othersSectionBg.backgroundColor = .darkGray()
        othersSectionBg.clipsToBounds = true
        othersSectionBg.layer.cornerRadius = GlobalCornerRadius.value
        mainScrollView.addSubview(othersSectionBg)
        let othersSectionBgHeight = 64 * 5 //depends on how many row
        othersSectionBg.snp.makeConstraints { (make) in
            make.height.equalTo(othersSectionBgHeight)
            make.width.equalTo(screenWidth - 40)
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(othersSectionDesc.snp.bottom).offset(15)
        }
        
        othersSectionTermsBtn = UIButton()
        othersSectionTermsBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        othersSectionTermsBtn.contentHorizontalAlignment = .left
        othersSectionTermsBtn.setTitle("Edit your profile", for: .normal)
        othersSectionTermsBtn.setTitleColor(.white, for: .normal)
        othersSectionTermsBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        othersSectionTermsBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        othersSectionBg.addSubview(othersSectionTermsBtn)
        othersSectionTermsBtn.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.width.equalToSuperview()
            make.top.left.equalToSuperview()
        }
        
        othersSectionTermsIcon = UIImageView()
        othersSectionTermsIcon.image = UIImage(named: "icon_apple_wallet")
        othersSectionBg.addSubview(othersSectionTermsIcon)
        othersSectionTermsIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(othersSectionTermsBtn)
            make.size.equalTo(24)
            make.right.equalTo(-20)
        }
        
        othersSectionSepLine = UIView()
        othersSectionSepLine.backgroundColor = .darkGray
        othersSectionSepLine.layer.cornerRadius = 0.5
        othersSectionBg.addSubview(othersSectionSepLine)
        othersSectionSepLine.snp.makeConstraints { (make) in
            make.top.equalTo(othersSectionTermsBtn.snp.bottom).offset(-1)
            make.left.equalTo(othersSectionBg.snp.left).offset(20)
            make.width.equalTo(screenWidth - 80)
            make.height.equalTo(2)
        }
        
        othersSectionPrivacyBtn = UIButton()
        othersSectionPrivacyBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        othersSectionPrivacyBtn.contentHorizontalAlignment = .left
        othersSectionPrivacyBtn.setTitle("Edit your events?", for: .normal)
        othersSectionPrivacyBtn.setTitleColor(.white, for: .normal)
        othersSectionPrivacyBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        othersSectionPrivacyBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        othersSectionBg.addSubview(othersSectionPrivacyBtn)
        othersSectionPrivacyBtn.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.width.equalToSuperview()
            make.top.equalTo(othersSectionTermsBtn.snp.bottom)
            make.left.equalToSuperview()
        }
        
        othersSectionPrivacyIcon = UIImageView()
        othersSectionPrivacyIcon.image = UIImage(named: "icon_confused")
        othersSectionBg.addSubview(othersSectionPrivacyIcon)
        othersSectionPrivacyIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(othersSectionPrivacyBtn)
            make.size.equalTo(24)
            make.right.equalTo(-20)
        }
        
        othersSectionSepLine2 = UIView()
        othersSectionSepLine2.backgroundColor = .darkGray
        othersSectionSepLine2.layer.cornerRadius = 0.5
        othersSectionBg.addSubview(othersSectionSepLine2)
        othersSectionSepLine2.snp.makeConstraints { (make) in
            make.top.equalTo(othersSectionPrivacyBtn.snp.bottom).offset(-1)
            make.left.equalTo(othersSectionBg.snp.left).offset(20)
            make.width.equalTo(screenWidth - 80)
            make.height.equalTo(2)
        }
        
        othersSectionFeedbackBtn = UIButton()
        othersSectionFeedbackBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        othersSectionFeedbackBtn.contentHorizontalAlignment = .left
        othersSectionFeedbackBtn.setTitle("Edit your posts", for: .normal)
        othersSectionFeedbackBtn.setTitleColor(.white, for: .normal)
        othersSectionFeedbackBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        othersSectionFeedbackBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        othersSectionBg.addSubview(othersSectionFeedbackBtn)
        othersSectionFeedbackBtn.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.width.equalToSuperview()
            make.top.equalTo(othersSectionPrivacyBtn.snp.bottom)
            make.left.equalToSuperview()
        }
        
        othersSectionFeedbackIcon = UIImageView()
        othersSectionFeedbackIcon.image = UIImage(named: "icon_google")
        othersSectionBg.addSubview(othersSectionFeedbackIcon)
        othersSectionFeedbackIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(othersSectionFeedbackBtn)
            make.size.equalTo(24)
            make.right.equalTo(-20)
        }
        
        othersSectionSepLine3 = UIView()
        othersSectionSepLine3.backgroundColor = .darkGray
        othersSectionSepLine3.layer.cornerRadius = 0.5
        othersSectionBg.addSubview(othersSectionSepLine3)
        othersSectionSepLine3.snp.makeConstraints { (make) in
            make.top.equalTo(othersSectionFeedbackBtn.snp.bottom).offset(-1)
            make.left.equalTo(othersSectionBg.snp.left).offset(20)
            make.width.equalTo(screenWidth - 80)
            make.height.equalTo(2)
        }

        othersSectionRateBtn = UIButton()
        othersSectionRateBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        othersSectionRateBtn.contentHorizontalAlignment = .left
        othersSectionRateBtn.setTitle("Edit your posts", for: .normal)
        othersSectionRateBtn.setTitleColor(.white, for: .normal)
        othersSectionRateBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        othersSectionRateBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        othersSectionBg.addSubview(othersSectionRateBtn)
        othersSectionRateBtn.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.width.equalToSuperview()
            make.top.equalTo(othersSectionFeedbackBtn.snp.bottom)
            make.left.equalToSuperview()
        }
        
        othersSectionRateIcon = UIImageView()
        othersSectionRateIcon.image = UIImage(named: "icon_google")
        othersSectionBg.addSubview(othersSectionRateIcon)
        othersSectionRateIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(othersSectionRateBtn)
            make.size.equalTo(24)
            make.right.equalTo(-20)
        }
        
        othersSectionSepLine4 = UIView()
        othersSectionSepLine4.backgroundColor = .darkGray
        othersSectionSepLine4.layer.cornerRadius = 0.5
        othersSectionBg.addSubview(othersSectionSepLine4)
        othersSectionSepLine4.snp.makeConstraints { (make) in
            make.top.equalTo(othersSectionRateBtn.snp.bottom).offset(-1)
            make.left.equalTo(othersSectionBg.snp.left).offset(20)
            make.width.equalTo(screenWidth - 80)
            make.height.equalTo(2)
        }
        
        othersSectionAboutBtn = UIButton()
        othersSectionAboutBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        othersSectionAboutBtn.contentHorizontalAlignment = .left
        othersSectionAboutBtn.setTitle("Edit your posts", for: .normal)
        othersSectionAboutBtn.setTitleColor(.white, for: .normal)
        othersSectionAboutBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        othersSectionAboutBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        othersSectionBg.addSubview(othersSectionAboutBtn)
        othersSectionAboutBtn.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.width.equalToSuperview()
            make.top.equalTo(othersSectionRateBtn.snp.bottom)
            make.left.equalToSuperview()
        }

        othersSectionAboutIcon = UIImageView()
        othersSectionAboutIcon.image = UIImage(named: "icon_google")
        othersSectionBg.addSubview(othersSectionAboutIcon)
        othersSectionAboutIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(othersSectionAboutBtn)
            make.size.equalTo(24)
            make.right.equalTo(-20)
        }
    }
}
