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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .m7DarkGray()
        
        animationView = AnimationView(name: "code")
        //animationView.frame = CGRect(x: 0, y: 0, width: 310, height: 223)
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        view.addSubview(animationView)

        animationView.snp.makeConstraints { (make) in
            //make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.center.equalToSuperview()
            make.size.equalTo(300)
            //make.centerX.equalToSuperview()
        }
        
        
        let lbl = UILabel()
        lbl.text = "Coming soon..."
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        view.addSubview(lbl)
        
        lbl.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(25)
            make.top.equalTo(animationView.snp.bottom)
        }
        
        animationView.play { _ in
            print("finished!!!")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationView.play { _ in
            print("finished!!!")
        }
    }
}
