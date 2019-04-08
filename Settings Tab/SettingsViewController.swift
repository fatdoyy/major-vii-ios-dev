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
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
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
        
        logInOrOutBtn.isHidden = true
        if UserService.User.isLoggedIn() {
            logInOrOutBtn.setTitle("Log Out", for: .normal)
        } else {
            logInOrOutBtn.setTitle("Log In", for: .normal)
        }
        
        mainScrollView.contentInsetAdjustmentBehavior = .never
        mainScrollView.showsVerticalScrollIndicator = false

        setupHeaderSection()
        setupGeneralSection()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainScrollView.contentSize = CGSize(width: screenWidth, height: UIScreen.main.bounds.height + 300)
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
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-42)
                
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
    }
}
