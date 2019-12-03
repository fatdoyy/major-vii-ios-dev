//
//  SettingsViewController.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import Pastel

class SettingsViewController: UIViewController {
    weak var previousController: UIViewController? //for tabbar scroll to top
    
    let screenWidth = UIScreen.main.bounds.width
    
    var mainScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    //Header
    var buskerNameLabel: UILabel!
    var accountTypeLabel: UILabel!
    var logoutBtn: UIButton!
    var buskerIcon: UIImageView!
    var loggedInHeaderViews = [UIView]()
    var emptyLoginBgView: UIView!
    var emptyLoginGradientBg: PastelView!
    var loginShadowView: UIView!
    var loginBtn: UIButton!
    var headerSectionTotalHeight: CGFloat!
    
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
    var generalSectionTotalHeight: CGFloat!
    
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
    var buskerSectionTotalHeight: CGFloat!
    
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
    var othersSectionTotalHeight: CGFloat!
    
    //Footer Section
    let appName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    let appVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    var versionLabel: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .m7DarkGray()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        //contentView.backgroundColor = .darkGray()

        mainScrollView = UIScrollView()
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.contentInsetAdjustmentBehavior = .never
        mainScrollView.contentInset = UIEdgeInsets.zero
        //mainScrollView.delegate = self
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.backgroundColor = .m7DarkGray()
        view.addSubview(mainScrollView)
        mainScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }

        setupHeaderSection()
        setupGeneralSection()
        setupBuskerSection()
        setupOthersSection()
        setupFooterSetction()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
        UIApplication.shared.statusBarUIView?.backgroundColor = .m7DarkGray()
        
        //show OR hide header
        if UserService.current.isLoggedIn() { //update username
            buskerNameLabel.text = "Hello, \(UserDefaults.standard.string(forKey: LOCAL_KEY.USERNAME) ?? "")!"
        }
        for view in loggedInHeaderViews {
            view.alpha = UserService.current.isLoggedIn() ? 1 : 0
        }
        loginShadowView.alpha = UserService.current.isLoggedIn() ? 0 : 1
        loginBtn.alpha = UserService.current.isLoggedIn() ? 0 : 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarUIView?.backgroundColor = .clear
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //mainScrollView.contentSize = CGSize(width: screenWidth, height: UIScreen.main.bounds.height + 800)
        let height = headerSectionTotalHeight + generalSectionTotalHeight + buskerSectionTotalHeight + othersSectionTotalHeight
        mainScrollView.contentSize = CGSize(width: screenWidth, height: height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupNavBar() {
        navigationItem.title = ""
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.m7DarkGray()]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
}

//MARK: - Header Section
extension SettingsViewController {
    private func setupHeaderSection() {
        setupLoggedInHeader()
        setupLoginHeader()
        
        for view in loggedInHeaderViews {
            view.alpha = UserService.current.isLoggedIn() ? 1 : 0
        }
        loginShadowView.alpha = UserService.current.isLoggedIn() ? 0 : 1
        loginBtn.alpha = UserService.current.isLoggedIn() ? 0 : 1
    }
    
    private func setupLoggedInHeader() {
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
        loggedInHeaderViews.append(buskerNameLabel)
        
        accountTypeLabel = UILabel()
        accountTypeLabel.textColor = .purpleText()
        accountTypeLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        accountTypeLabel.text = "(Busker)"
        mainScrollView.addSubview(accountTypeLabel)
        accountTypeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(buskerNameLabel.snp.bottom)
            make.left.equalTo(buskerNameLabel.snp.left)
        }
        loggedInHeaderViews.append(accountTypeLabel)
        
        logoutBtn = UIButton()
        logoutBtn.setTitle("Logout", for: .normal)
        logoutBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        logoutBtn.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        logoutBtn.layer.cornerRadius = 3
        logoutBtn.addTarget(self, action: #selector(didTapLogoutBtn), for: .touchUpInside)
        mainScrollView.addSubview(logoutBtn)
        logoutBtn.snp.makeConstraints { (make) in
            make.top.equalTo(accountTypeLabel.snp.bottom).offset(10)
            make.width.equalTo(100)
            make.height.equalTo(28)
            make.left.equalTo(accountTypeLabel.snp.left)
        }
        loggedInHeaderViews.append(logoutBtn)
        
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
        loggedInHeaderViews.append(buskerIcon)
        
        headerSectionTotalHeight = 306 //padding
    }
    
    private func setupLoginHeader() {
        //empty view's drop shadow
        loginShadowView = UIView()
        loginShadowView.alpha = 1
        loginShadowView.frame = CGRect(x: 20, y: 78, width: UIScreen.main.bounds.width - 40, height: 106)
        loginShadowView.clipsToBounds = false
        loginShadowView.layer.shadowOpacity = 0.5
        loginShadowView.layer.shadowOffset = CGSize(width: -1, height: -1)
        loginShadowView.layer.shadowRadius = GlobalCornerRadius.value
        loginShadowView.layer.shadowPath = UIBezierPath(roundedRect: loginShadowView.bounds, cornerRadius: GlobalCornerRadius.value).cgPath
        
        //empty view
        //bgView.alpha = 0
        emptyLoginBgView = UIView()
        emptyLoginBgView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: 106)
        emptyLoginBgView.layer.cornerRadius = GlobalCornerRadius.value
        emptyLoginBgView.clipsToBounds = true
        emptyLoginBgView.backgroundColor = .darkGray
        
        //gradient bg
        emptyLoginGradientBg = PastelView()
        emptyLoginGradientBg.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: 106)
        emptyLoginGradientBg.animationDuration = 2.5
        emptyLoginGradientBg.setColors([UIColor(hexString: "#FDC830"), UIColor(hexString: "#F37335")])
        loginShadowView.layer.shadowColor = UIColor(hexString: "#FDC830").cgColor
        
        emptyLoginGradientBg.startAnimation()
        
        emptyLoginBgView.insertSubview(emptyLoginGradientBg, at: 0)
        loginShadowView.addSubview(emptyLoginBgView)
        
        let loginImgView = UIImageView()
        loginImgView.image = UIImage(named: "icon_login")
        emptyLoginBgView.addSubview(loginImgView)
        loginImgView.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.size.equalTo(40)
        }

        let loginTitle = UILabel()
        loginTitle.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        loginTitle.text = "Log-in now!"
        loginTitle.textColor = .white
        emptyLoginBgView.addSubview(loginTitle)
        loginTitle.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.left.equalTo(loginImgView.snp.right).offset(5)
        }

        let loginDesc = UILabel()
        loginDesc.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        loginDesc.text = "Enjoy full experience with your Major VII account."
        loginDesc.textColor = .white
        loginDesc.numberOfLines = 2
        emptyLoginBgView.addSubview(loginDesc)
        loginDesc.snp.makeConstraints { (make) in
            make.top.equalTo(loginTitle.snp.bottom).offset(10)
            make.left.equalTo(25)
            make.width.equalTo(220)
        }
        
        loginBtn = UIButton()
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        loginBtn.layer.cornerRadius = GlobalCornerRadius.value / 2
        loginBtn.setTitle("Sure!", for: .normal)
        loginBtn.setTitleColor(UIColor(hexString: "#F37335"), for: .normal)
        loginBtn.backgroundColor = .white
        loginBtn.addTarget(self, action: #selector(showLoginVC), for: .touchUpInside)
        mainScrollView.addSubview(loginBtn)
        loginBtn.snp.makeConstraints { (make) in
            make.top.equalTo(logoutBtn.snp.top)
            make.right.equalTo(buskerNameLabel.snp.right).offset(-15)
            make.width.equalTo(60)
            make.height.equalTo(28)
        }
        
        mainScrollView.addSubview(loginShadowView)
        mainScrollView.bringSubviewToFront(loginBtn)
        loginShadowView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(98)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(screenWidth - 40)
        }
    }
    
    @objc func showLoginVC(_ sender: Any) {
        let loginVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        print("tapped")
        self.present(loginVC, animated: true, completion: nil)
    }
    
    @objc func didTapLogoutBtn(_ sender: Any) {
        logoutBtn.setTitle("Logging out...", for: .normal)
        UserService.current.logout(fromVC: self).done { _ -> () in
            UIView.animate(withDuration: 0.2) {
                self.loginShadowView.alpha = 1
                self.loginBtn.alpha = 1
            }
            self.logoutBtn.setTitle("Logout", for: .normal) //reset title
        }.catch { error in }
    }
}

//MARK: - General Settings Section
extension SettingsViewController {
    private func setupGeneralSection() {
        generalSectionTitle = UILabel()
        generalSectionTitle.text = "General Settings"
        generalSectionTitle.textColor = .white
        generalSectionTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        mainScrollView.addSubview(generalSectionTitle)
        let generalSectionTitleHeight: CGFloat = 21
        generalSectionTitle.snp.makeConstraints { (make) in
            make.top.equalTo(logoutBtn.snp.bottom).offset(44)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(generalSectionTitleHeight)
        }
        
        generalSettingsDesc = UILabel()
        generalSettingsDesc.text = "Configure your personal settings"
        generalSettingsDesc.textColor = .white
        generalSettingsDesc.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        mainScrollView.addSubview(generalSettingsDesc)
        let generalSectionDescHeight: CGFloat = 14
        generalSettingsDesc.snp.makeConstraints { (make) in
            make.top.equalTo(generalSectionTitle.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(generalSectionDescHeight)
        }
        
        generalSectionBg = UIView()
        generalSectionBg.backgroundColor = .m7DarkGray()
        generalSectionBg.clipsToBounds = true
        generalSectionBg.layer.cornerRadius = GlobalCornerRadius.value
        mainScrollView.addSubview(generalSectionBg)
        let generalSectionBgHeight: CGFloat = 64 * 3
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
        generalSectionNotiBtn.setTitleColor(.darkGray, for: .normal)
        generalSectionNotiBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        generalSectionNotiBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        generalSectionNotiBtn.addTarget(self, action: #selector(notiBtnTapped), for: .touchUpInside)
        generalSectionBg.addSubview(generalSectionNotiBtn)
        generalSectionNotiBtn.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.width.equalToSuperview()
            make.top.left.equalToSuperview()
        }

        generalSectionNotiIcon = UIImageView()
        generalSectionNotiIcon.image = UIImage(named: "settings_icon_noti")?.withRenderingMode(.alwaysTemplate)
        generalSectionNotiIcon.tintColor = .darkGray
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
        generalSectionBuskerRegBtn.setTitleColor(.darkGray, for: .normal)
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
        generalSectionRegIcon.image = UIImage(named: "settings_icon_performer")?.withRenderingMode(.alwaysTemplate)
        generalSectionRegIcon.tintColor = .darkGray
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
        generalSectionSettingsBtn.setTitleColor(.darkGray, for: .normal)
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
        generalSectionSettingsIcon.image = UIImage(named: "settings_icon_settings")?.withRenderingMode(.alwaysTemplate)
        generalSectionSettingsIcon.tintColor = .darkGray
        generalSectionBg.addSubview(generalSectionSettingsIcon)
        generalSectionSettingsIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(generalSectionSettingsBtn)
            make.size.equalTo(24)
            make.right.equalTo(-20)
        }
        
        generalSectionTotalHeight = generalSectionTitleHeight + generalSectionDescHeight + generalSectionBgHeight + 63 //padding
    }
    
    @objc func notiBtnTapped() {
        print("notiBtnTapped")
    }
}

//MARK: - Account Details (Busker) Section
extension SettingsViewController {
    private func setupBuskerSection() {
        buskerSectionTitle = UILabel()
        buskerSectionTitle.text = "Account Details"
        buskerSectionTitle.textColor = .white
        buskerSectionTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        mainScrollView.addSubview(buskerSectionTitle)
        let buskerSectionTitleHeight: CGFloat = 21
        buskerSectionTitle.snp.makeConstraints { (make) in
            make.top.equalTo(generalSectionBg.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(buskerSectionTitleHeight)
        }
        
        buskerSectionDesc = UILabel()
        buskerSectionDesc.text = "View or edit your Major VII account details"
        buskerSectionDesc.textColor = .white
        buskerSectionDesc.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        mainScrollView.addSubview(buskerSectionDesc)
        let buskerSectionDescHeight: CGFloat = 14
        buskerSectionDesc.snp.makeConstraints { (make) in
            make.top.equalTo(buskerSectionTitle.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(buskerSectionDescHeight)
        }
        
        buskerSectionBg = UIView()
        buskerSectionBg.backgroundColor = .m7DarkGray()
        buskerSectionBg.clipsToBounds = true
        buskerSectionBg.layer.cornerRadius = GlobalCornerRadius.value
        mainScrollView.addSubview(buskerSectionBg)
        let buskerSectionBgHeight: CGFloat = 64 * 3 //depends on how many row
        buskerSectionBg.snp.makeConstraints { (make) in
            make.height.equalTo(buskerSectionBgHeight)
            make.width.equalTo(screenWidth - 40)
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(buskerSectionDesc.snp.bottom).offset(15)
        }
        
        buskerSectionProfileBtn = UIButton()
        buskerSectionProfileBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        buskerSectionProfileBtn.contentHorizontalAlignment = .left
        buskerSectionProfileBtn.setTitle("Edit your profile", for: .normal)
        buskerSectionProfileBtn.setTitleColor(.darkGray, for: .normal)
        buskerSectionProfileBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        buskerSectionProfileBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        buskerSectionBg.addSubview(buskerSectionProfileBtn)
        buskerSectionProfileBtn.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.width.equalToSuperview()
            make.top.left.equalToSuperview()
        }
        
        buskerSectionProfileIcon = UIImageView()
        buskerSectionProfileIcon.image = UIImage(named: "settings_icon_profile")?.withRenderingMode(.alwaysTemplate)
        buskerSectionProfileIcon.tintColor = .darkGray
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
        buskerSectionEventBtn.setTitleColor(.darkGray, for: .normal)
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
        buskerSectionEventIcon.image = UIImage(named: "settings_icon_events")?.withRenderingMode(.alwaysTemplate)
        buskerSectionEventIcon.tintColor = .darkGray
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
        buskerSectionPostBtn.setTitleColor(.darkGray, for: .normal)
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
        buskerSectionPostIcon.image = UIImage(named: "settings_icon_posts")?.withRenderingMode(.alwaysTemplate)
        buskerSectionPostIcon.tintColor = .darkGray
        buskerSectionBg.addSubview(buskerSectionPostIcon)
        buskerSectionPostIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(buskerSectionPostBtn)
            make.size.equalTo(24)
            make.right.equalTo(-20)
        }
        
        buskerSectionTotalHeight = buskerSectionTitleHeight + buskerSectionDescHeight + buskerSectionBgHeight + 49 //padding
    }
}

//MARK: - Other Section
extension SettingsViewController {
    private func setupOthersSection() {
        othersSectionTitle = UILabel()
        othersSectionTitle.text = "Others"
        othersSectionTitle.textColor = .white
        othersSectionTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        mainScrollView.addSubview(othersSectionTitle)
        let othersSectionTitleHeight: CGFloat = 21
        othersSectionTitle.snp.makeConstraints { (make) in
            make.top.equalTo(buskerSectionBg.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(othersSectionTitleHeight)
        }
        
        othersSectionDesc = UILabel()
        othersSectionDesc.text = "Configure other settings"
        othersSectionDesc.textColor = .white
        othersSectionDesc.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        mainScrollView.addSubview(othersSectionDesc)
        let othersSectionDescHeight: CGFloat = 14
        othersSectionDesc.snp.makeConstraints { (make) in
            make.top.equalTo(othersSectionTitle.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(othersSectionDescHeight)
        }
        
        othersSectionBg = UIView()
        othersSectionBg.backgroundColor = .m7DarkGray()
        othersSectionBg.clipsToBounds = true
        othersSectionBg.layer.cornerRadius = GlobalCornerRadius.value
        mainScrollView.addSubview(othersSectionBg)
        let othersSectionBgHeight: CGFloat = 64 * 5 //depends on how many row
        othersSectionBg.snp.makeConstraints { (make) in
            make.height.equalTo(othersSectionBgHeight)
            make.width.equalTo(screenWidth - 40)
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(othersSectionDesc.snp.bottom).offset(15)
        }
        
        othersSectionTermsBtn = UIButton()
        othersSectionTermsBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        othersSectionTermsBtn.contentHorizontalAlignment = .left
        othersSectionTermsBtn.setTitle("Terms & Conditions", for: .normal)
        othersSectionTermsBtn.setTitleColor(.darkGray, for: .normal)
        othersSectionTermsBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        othersSectionTermsBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        othersSectionBg.addSubview(othersSectionTermsBtn)
        othersSectionTermsBtn.snp.makeConstraints { (make) in
            make.height.equalTo(64)
            make.width.equalToSuperview()
            make.top.left.equalToSuperview()
        }
        
        othersSectionTermsIcon = UIImageView()
        othersSectionTermsIcon.image = UIImage(named: "settings_icon_terms")?.withRenderingMode(.alwaysTemplate)
        othersSectionTermsIcon.tintColor = .darkGray
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
        othersSectionPrivacyBtn.setTitle("Privacy Policy", for: .normal)
        othersSectionPrivacyBtn.setTitleColor(.darkGray, for: .normal)
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
        othersSectionPrivacyIcon.image = UIImage(named: "settings_icon_privacy")?.withRenderingMode(.alwaysTemplate)
        othersSectionPrivacyIcon.tintColor = .darkGray
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
        othersSectionFeedbackBtn.setTitle("Send Feedback", for: .normal)
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
        othersSectionFeedbackIcon.image = UIImage(named: "settings_icon_feedback")?.withRenderingMode(.alwaysTemplate)
        othersSectionFeedbackIcon.tintColor = .white
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
        othersSectionRateBtn.setTitle("Rate us on App Store!", for: .normal)
        othersSectionRateBtn.setTitleColor(.darkGray, for: .normal)
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
        othersSectionRateIcon.image = UIImage(named: "settings_icon_rate")?.withRenderingMode(.alwaysTemplate)
        othersSectionRateIcon.tintColor = .darkGray
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
        othersSectionAboutBtn.setTitle("About", for: .normal)
        othersSectionAboutBtn.setTitleColor(.darkGray, for: .normal)
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
        othersSectionAboutIcon.image = UIImage(named: "settings_icon_about")?.withRenderingMode(.alwaysTemplate)
        othersSectionAboutIcon.tintColor = .darkGray
        othersSectionBg.addSubview(othersSectionAboutIcon)
        othersSectionAboutIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(othersSectionAboutBtn)
            make.size.equalTo(24)
            make.right.equalTo(-20)
        }
        
        othersSectionTotalHeight = othersSectionTitleHeight + othersSectionDescHeight + othersSectionBgHeight + 49 /* padding */
    }
}

//MARK: - Footer Section
extension SettingsViewController {
    private func setupFooterSetction() {
        versionLabel = UILabel()
        versionLabel.text = "\(appName) v\(appVersion) (\(buildNumber))"
        versionLabel.textColor = .pumpkin
        versionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        mainScrollView.addSubview(versionLabel)
        versionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(othersSectionBg.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
    }
}

//MARK: - UIGestureRecognizerDelegate (i.e. swipe pop gesture)
extension SettingsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: - Scroll to top when tabbar icon is tapped
extension SettingsViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if previousController == viewController || previousController == nil {
            // the same tab was tapped a second time
            let nav = viewController as! UINavigationController
            
            // if in first level of navigation (table view) then and only then scroll to top
            if nav.viewControllers.count < 2 {
                //let vc = nav.topViewController as! HomeViewController
                //tableCont.tableView.setContentOffset(CGPoint(x: 0.0, y: -tableCont.tableView.contentInset.top), animated: true)
                //vc.mainCollectionView.setContentOffset(CGPoint.zero, animated: true)
                mainScrollView.setContentOffset(CGPoint.zero, animated: true)
            }
        }
        previousController = viewController;
        return true
    }
}
