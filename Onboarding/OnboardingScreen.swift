//
//  OnboardingScreen.swift
//  major-7-ios
//
//  Created by jason on 12/12/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import Pastel
import SkyFloatingLabelTextField

class OnboardingScreen: UIViewController {
    var gradientBg: PastelView!
    var mainScrollView: UIScrollView!
    var pageSize: CGSize!
    
    //screen one
    var screenOneBg: UIView!
    var screenOneTitle: UILabel!
    var screenOneSubTitle: UILabel!
    var profilePic: UIImageView!
    var usernameField: SkyFloatingLabelTextField!
    var usernameDesc: UILabel!
    
    //screen two
    var screenTwoBg: UIView!
    var screenTwoTitle: UILabel!
    var screenTwoSubTitle: UILabel!
    
    //screen three
    var screenThreeBg: UIView!
    var screenThreeTitle: UILabel!
    var screenThreeSubTitle: UILabel!
    
    var isScreenOneAnimated = false
    var isScreenTwoAnimated = false
    var isScreenThreeAnimated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mainScrollView.contentSize = CGSize(width: pageSize.width * 3, height: pageSize.height - 100)
    }
}

//MARK: - UI related
extension OnboardingScreen {
    private func setupPastelView() {
        // Custom Direction
        gradientBg = PastelView()
        gradientBg.startPastelPoint = .bottomLeft
        gradientBg.endPastelPoint = .topRight
        
        // Custom Duration
        gradientBg.animationDuration = 2
        
        // Custom Color
        gradientBg.setColors([UIColor(hexString: "#ad5389"), UIColor(hexString: "#3c1053")])
        
        gradientBg.startAnimation()
        view.insertSubview(gradientBg, at: 0)
        gradientBg.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(0)
        }
    }
    
    private func setupScrollView() {
        pageSize = view.bounds.size

        mainScrollView = UIScrollView()
        mainScrollView.delegate = self
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.showsHorizontalScrollIndicator = false
        mainScrollView.isPagingEnabled = true
        mainScrollView.backgroundColor = .clear
        
        view.addSubview(mainScrollView)
        mainScrollView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.bottom.equalToSuperview().offset(-100)
        }
    }
    
    private func setupUI() {
        setupPastelView()
        setupScrollView()
        
        setupScreenOne()
        setupScreenTwo()
        setupScreenThree()
        
        animateScreenOne()
    }
}

//MARK: - Onboarding Screens UI
extension OnboardingScreen {
    private func setupScreenOne() {
        screenOneBg = UIView()
        screenOneBg.backgroundColor = .greenSea
        mainScrollView.addSubview(screenOneBg)
        screenOneBg.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.size.equalTo(pageSize)
        }
        
        screenOneTitle = UILabel()
        screenOneTitle.alpha = 0
        screenOneTitle.text = "Pick a username!"
        screenOneTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        screenOneTitle.textColor = .white
        screenOneBg.addSubview(screenOneTitle)
        screenOneTitle.snp.makeConstraints { (make) in
            make.top.equalTo(88)
            make.width.equalTo(pageSize.width - 60)
            make.left.equalTo(UIScreen.main.bounds.midX)
        }
        
        screenOneSubTitle = UILabel()
        screenOneSubTitle.alpha = 0
        screenOneSubTitle.text = "A great name helps you produce better music (joke)"
        screenOneSubTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        screenOneSubTitle.textColor = .white
        screenOneSubTitle.numberOfLines = 0
        screenOneBg.addSubview(screenOneSubTitle)
        screenOneSubTitle.snp.makeConstraints { (make) in
            make.top.equalTo(screenOneTitle.snp.bottom).offset(40)
            make.width.equalTo(UIScreen.main.bounds.width - 60)
            make.left.equalTo(screenOneTitle.snp.left)
        }
        
        profilePic = UIImageView()
        //profilePic.alpha = 0
        profilePic.layer.cornerRadius = 65
        profilePic.contentMode = .scaleAspectFill
        profilePic.backgroundColor = .darkGray
        screenOneBg.addSubview(profilePic)
        profilePic.snp.makeConstraints { (make) in
            make.top.equalTo(screenOneSubTitle.snp.bottom).offset(50)
            make.size.equalTo(130)
            make.centerX.equalToSuperview()
            make.left.equalTo(UIScreen.main.bounds.midX + 100)
        }

        usernameField = SkyFloatingLabelTextField()
        usernameField.alpha = 0
        usernameField.placeholder = "Username"
        usernameField.title = "Username"
        screenOneBg.addSubview(usernameField)
        usernameField.snp.makeConstraints { (make) in
            make.top.equalTo(profilePic.snp.bottom).offset(32)
            make.width.equalTo(200)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.left.equalTo(UIScreen.main.bounds.midX + 100)
        }

        usernameDesc = UILabel()
        usernameDesc.alpha = 0
        usernameDesc.text = "You can change this anytime!"
        usernameDesc.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        screenOneBg.addSubview(usernameDesc)
        usernameDesc.snp.makeConstraints { (make) in
            make.top.equalTo(usernameField.snp.bottom).offset(10)
            make.height.equalTo(17)
            make.centerX.equalToSuperview()
            make.left.equalTo(UIScreen.main.bounds.midX + 100)
        }
    }
    
    private func setupScreenTwo() {
        screenTwoBg = UIView()
        mainScrollView.addSubview(screenTwoBg)
        screenTwoBg.snp.makeConstraints { (make) in
            make.left.equalTo(screenOneBg.snp.right)
            make.size.equalTo(pageSize)
        }
        
        screenTwoTitle = UILabel()
        screenTwoTitle.alpha = 0
        screenTwoTitle.text = "Pick your genres!"
        screenTwoTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        screenTwoTitle.textColor = .white
        screenTwoBg.addSubview(screenTwoTitle)
        screenTwoTitle.snp.makeConstraints { (make) in
            make.top.equalTo(88)
            make.width.equalTo(pageSize.width - 60)
            make.left.equalTo(UIScreen.main.bounds.midX)
        }
        
        screenTwoSubTitle = UILabel()
        screenTwoSubTitle.alpha = 0
        screenTwoSubTitle.text = "This help us suggest suitable artists for you"
        screenTwoSubTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        screenTwoSubTitle.textColor = .white
        screenTwoSubTitle.numberOfLines = 0
        screenTwoBg.addSubview(screenTwoSubTitle)
        screenTwoSubTitle.snp.makeConstraints { (make) in
            make.top.equalTo(screenTwoTitle.snp.bottom).offset(40)
            make.width.equalTo(UIScreen.main.bounds.width - 60)
            make.left.equalTo(screenTwoTitle.snp.left)
        }
    }
    
    private func setupScreenThree() {
        screenThreeBg = UIView()
        mainScrollView.addSubview(screenThreeBg)
        screenThreeBg.snp.makeConstraints { (make) in
            make.left.equalTo(screenTwoBg.snp.right)
            make.size.equalTo(pageSize)
            make.right.equalToSuperview()
        }
        
        screenThreeTitle = UILabel()
        screenThreeTitle.alpha = 0
        screenThreeTitle.text = "Notifications"
        screenThreeTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        screenThreeTitle.textColor = .white
        screenThreeBg.addSubview(screenThreeTitle)
        screenThreeTitle.snp.makeConstraints { (make) in
            make.top.equalTo(88)
            make.width.equalTo(pageSize.width - 60)
            make.left.equalTo(UIScreen.main.bounds.midX)
            //make.right.equalTo(-30) //setup right side constraint on last screen
        }
        
        screenThreeSubTitle = UILabel()
        screenThreeSubTitle.alpha = 0
        screenThreeSubTitle.text = "請允許我們向你提供推送通知，例如表演者將舉行表演的時間地點 、本地音樂消息等等。\n\n你稍後可在設定中變更通知選項。"
        screenThreeSubTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        screenThreeSubTitle.textColor = .white
        screenThreeSubTitle.numberOfLines = 0
        screenThreeBg.addSubview(screenThreeSubTitle)
        screenThreeSubTitle.snp.makeConstraints { (make) in
            make.top.equalTo(screenThreeTitle.snp.bottom).offset(40)
            make.width.equalTo(UIScreen.main.bounds.width - 60)
            make.left.equalTo(screenThreeTitle.snp.left)
            //make.right.equalToSuperview().offset(-30) //setup right side constraint on last screen
        }
    }
}

//MARK: - Animations
extension OnboardingScreen {
    private func animateScreenOne() {
        let originalTransform = screenOneTitle.transform
        let translatedTransform = originalTransform.translatedBy(x: -UIScreen.main.bounds.midX + 30, y: -0)
        
        UIView.animate(withDuration: 0.65, delay: 0.1, options: .curveEaseInOut, animations: {
            self.screenOneTitle.transform = translatedTransform
            self.screenOneTitle.alpha = 1
        }, completion: nil)
                        
        UIView.animate(withDuration: 0.65, delay: 0.3, options: .curveEaseInOut, animations: {
            self.screenOneSubTitle.transform = translatedTransform
            self.screenOneSubTitle.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 0.65, delay: 0.5, options: .curveEaseInOut, animations: {
            //self.screenOneSubTitle.transform = translatedTransform
            self.profilePic.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 0.65, delay: 0.7, options: .curveEaseInOut, animations: {
            //self.screenOneSubTitle.transform = translatedTransform
            self.usernameField.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 0.65, delay: 0.9, options: .curveEaseInOut, animations: {
            //self.screenOneSubTitle.transform = translatedTransform
            self.usernameDesc.alpha = 1
        }, completion: nil)
        
        isScreenOneAnimated = true
    }
    
    private func animateScreenTwo() {
        let originalTransform = screenTwoTitle.transform
        let translatedTransform = originalTransform.translatedBy(x: -UIScreen.main.bounds.midX + 30, y: -0)
        
        UIView.animate(withDuration: 0.65, delay: 0, options: .curveEaseInOut, animations: {
            self.screenTwoTitle.transform = translatedTransform
            self.screenTwoTitle.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 0.65, delay: 0.2, options: .curveEaseInOut, animations: {
            self.screenTwoSubTitle.transform = translatedTransform
            self.screenTwoSubTitle.alpha = 1
        }, completion: nil)
        
        isScreenTwoAnimated = true
    }
    
    private func animateScreenThree() {
        let originalTransform = screenThreeTitle.transform
        let translatedTransform = originalTransform.translatedBy(x: -UIScreen.main.bounds.midX + 30, y: -0)
        
        UIView.animate(withDuration: 0.65, delay: 0, options: .curveEaseInOut, animations: {
            self.screenThreeTitle.transform = translatedTransform
            self.screenThreeTitle.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 0.65, delay: 0.2, options: .curveEaseInOut, animations: {
            self.screenThreeSubTitle.transform = translatedTransform
            self.screenThreeSubTitle.alpha = 1
        }, completion: nil)
        
        isScreenThreeAnimated = true
    }
}

//MARK: - UIScrollView delegate
extension OnboardingScreen: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = scrollView.contentOffset.x / scrollView.bounds.size.width
        /// initiate animations on half way before user scrolls to next page (i.e. pageIndex == 1)
        if pageIndex > 0.35 && !isScreenTwoAnimated   { animateScreenTwo() }
        if pageIndex > 1.35 && !isScreenThreeAnimated { animateScreenThree() }
    }
}
