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
    var mainTitle: UILabel!
    var subTitle: UILabel!
    
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
        //mainScrollView.delegate = self
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.showsHorizontalScrollIndicator = false
        mainScrollView.isPagingEnabled = true
        mainScrollView.backgroundColor = .pumpkin
        
        view.addSubview(mainScrollView)
        mainScrollView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.bottom.equalToSuperview().offset(-100)
        }
    }
    
    private func setupUI() {
        setupPastelView()
        setupScrollView()
        
        mainTitle = UILabel()
        mainTitle.text = "Pick a username!"
        mainTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        mainTitle.textColor = .white
        mainScrollView.addSubview(mainTitle)
        mainTitle.snp.makeConstraints { (make) in
            make.top.equalTo(88)
            make.left.equalTo(30)
            make.right.equalTo(-30)
        }
        
        subTitle = UILabel()
        subTitle.text = "A great name helps you produce better music (joke)"
        subTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        subTitle.textColor = .white
        subTitle.numberOfLines = 0
        mainScrollView.addSubview(subTitle)
        subTitle.snp.makeConstraints { (make) in
            make.top.equalTo(mainTitle.snp.bottom).offset(36)
            //make.width.equalTo(UIScreen.main.bounds.width - 60)
            make.left.equalTo(mainTitle.snp.left)
            make.right.equalToSuperview().offset(-30)
        }
        
        let box = UIView()
        box.backgroundColor = .blue
        mainScrollView.addSubview(box)
        box.snp.makeConstraints { (make) in
            make.top.equalTo(subTitle.snp.bottom).offset(50)
            make.size.equalTo(200)
            make.right.equalToSuperview().offset(130)
        }
    }
}

