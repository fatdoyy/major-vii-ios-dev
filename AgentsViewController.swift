//
//  AgentsViewController.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import Lottie

class AgentsViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var animationView: AnimationView!
    var animationView2: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .m7DarkGray()
        
        animationView = AnimationView(name: "2020")
        animationView.frame = CGRect(x: 0, y: 0, width: 310, height: 223)
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        
        view.addSubview(animationView)
        animationView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        animationView.play { _ in
            print("finished!!!")
        }
        
        animationView2 = AnimationView(name: "nyan-cat")
        animationView2.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        animationView2.contentMode = .scaleAspectFill
        animationView2.loopMode = .loop
        
        view.addSubview(animationView2)
        animationView2.snp.makeConstraints { (make) in
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
            make.centerY.equalToSuperview().offset(-20)
        }
        
        animationView2.play { _ in
            print("finished!!!")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationView.play { _ in
            print("finished!!!")
        }
        
        animationView2.play { _ in
            print("finished!!!")
        }
    }
    
}
