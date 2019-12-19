//
//  OnboardingScreen.swift
//  major-7-ios
//
//  Created by jason on 12/12/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import Pastel

class OnboardingScreen: UIViewController {
    var gradientBg: PastelView!
    var mainScrollView: UIScrollView!
    var pageSize: CGSize!
    
    var screenOneTitle: UILabel!
    var screenOneSubTitle: UILabel!
    var screenTwoTitle: UILabel!
    var screenTwoSubTitle: UILabel!
    var screenThreeTitle: UILabel!
    var screenThreeSubTitle: UILabel!
    
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
        
        animate()
    }
}

//MARK: - Onboarding Screens UI
extension OnboardingScreen {
    private func setupScreenOne() {
        screenOneTitle = UILabel()
        //screenOneTitle.alpha = 0
        screenOneTitle.backgroundColor = .pumpkin
        screenOneTitle.text = "Pick a username!"
        screenOneTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        screenOneTitle.textColor = .white
        mainScrollView.addSubview(screenOneTitle)
        screenOneTitle.snp.makeConstraints { (make) in
            make.top.equalTo(88)
            make.width.equalTo(UIScreen.main.bounds.width - 60)
            make.left.equalTo(UIScreen.main.bounds.midX)
        }
        
        screenOneSubTitle = UILabel()
        screenOneSubTitle.text = "A great name helps you produce better music (joke)"
        screenOneSubTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        screenOneSubTitle.textColor = .white
        screenOneSubTitle.numberOfLines = 0
        mainScrollView.addSubview(screenOneSubTitle)
        screenOneSubTitle.snp.makeConstraints { (make) in
            make.top.equalTo(screenOneTitle.snp.bottom).offset(46)
            make.width.equalTo(UIScreen.main.bounds.width - 60)
            make.left.equalTo(screenOneTitle.snp.left)
        }
    }
    
    private func setupScreenTwo() {
        screenTwoTitle = UILabel()
        screenTwoTitle.text = "Pick your genres!"
        screenTwoTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        screenTwoTitle.textColor = .white
        mainScrollView.addSubview(screenTwoTitle)
        screenTwoTitle.snp.makeConstraints { (make) in
            make.top.equalTo(88)
            make.width.equalTo(UIScreen.main.bounds.width - 60)
            make.left.equalTo(screenOneTitle.snp.right).offset(60)
        }
        
        screenTwoSubTitle = UILabel()
        screenTwoSubTitle.text = "This help us suggest suitable artists for you"
        screenTwoSubTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        screenTwoSubTitle.textColor = .white
        screenTwoSubTitle.numberOfLines = 0
        mainScrollView.addSubview(screenTwoSubTitle)
        screenTwoSubTitle.snp.makeConstraints { (make) in
            make.top.equalTo(screenTwoTitle.snp.bottom).offset(46)
            make.width.equalTo(UIScreen.main.bounds.width - 60)
            make.left.equalTo(screenTwoTitle.snp.left)
        }
    }
    
    private func setupScreenThree() {
        screenThreeTitle = UILabel()
        screenThreeTitle.text = "Notifications"
        screenThreeTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        screenThreeTitle.textColor = .white
        mainScrollView.addSubview(screenThreeTitle)
        screenThreeTitle.snp.makeConstraints { (make) in
            make.top.equalTo(88)
            make.width.equalTo(UIScreen.main.bounds.width - 60)
            make.left.equalTo(screenTwoTitle.snp.right).offset(60)
            make.right.equalTo(-30) //setup right side constraint on last screen
        }
        
        screenThreeSubTitle = UILabel()
        screenThreeSubTitle.text = "請允許我們向你提供推送通知，例如表演者將舉行表演的時間地點 、本地音樂消息等等。\n\n你稍後可在設定中變更通知選項。"
        screenThreeSubTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        screenThreeSubTitle.textColor = .white
        screenThreeSubTitle.numberOfLines = 0
        mainScrollView.addSubview(screenThreeSubTitle)
        screenThreeSubTitle.snp.makeConstraints { (make) in
            make.top.equalTo(screenThreeTitle.snp.bottom).offset(46)
            make.width.equalTo(UIScreen.main.bounds.width - 60)
            make.left.equalTo(screenThreeTitle.snp.left)
            make.right.equalToSuperview().offset(-30) //setup right side constraint on last screen
        }
    }
    
    private func animate() {
        let originalTransform = screenOneTitle.transform
        let translatedTransform = originalTransform.translatedBy(x: -UIScreen.main.bounds.midX + 30, y: -0)
        
        UIView.animate(withDuration: 0.7, delay: 0.2, options: .curveEaseInOut, animations: {
            self.screenOneTitle.transform = translatedTransform
            self.screenOneTitle.alpha = 1
        }, completion: { _ in
//            self.screenOneTitle.snp.updateConstraints { (make) in
//                make.left.equalTo(30)
//            }
        })
        
        UIView.animate(withDuration: 0.6, delay: 0.4, options: .curveEaseInOut, animations: {
            self.screenOneSubTitle.transform = translatedTransform
        }, completion: { _ in
            
        })
    }
}

//MARK: - UIScrollView delegate
extension OnboardingScreen: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        print("pageIndex = \(pageIndex)")
        if pageIndex == 1 {
//            createHeroTransitions()
        }
    }
}
