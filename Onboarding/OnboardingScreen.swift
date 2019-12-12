//
//  OnboardingScreen.swift
//  major-7-ios
//
//  Created by jason on 12/12/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import paper_onboarding

class OnboardingScreen: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPaperOnboarding()
    }
}

//MARK: - Onboarding Screen UI
extension OnboardingScreen {
    func setupPaperOnboarding() {
        let onboarding = PaperOnboarding()
        onboarding.dataSource = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        onboarding.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        addCustomView(onboarding)
    }
    
    func addCustomView(_ view: PaperOnboarding) {
        let box = UIView()
        box.backgroundColor = .blue
        view.addSubview(box)
        box.snp.makeConstraints { (make) in
            make.size.equalTo(30)
            make.center.equalToSuperview()
        }
    }
}
