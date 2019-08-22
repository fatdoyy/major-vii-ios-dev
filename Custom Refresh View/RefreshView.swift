//
//  RefreshView.swift
//  CustomRefreshControl
//
//  Created by Yudiz on 18/04/18.
//  Copyright © 2018 Yudiz. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class RefreshView: UIView {
    
    @IBOutlet weak var refreshBg: UIImageView!
    @IBOutlet weak var logo: UIImageView!
    var indicator: NVActivityIndicatorView!
    var view: UIView!
    
    var gradientView: UIView!
}

// MARK: - UI Related
extension RefreshView {
    fileprivate func initializeGradientView() {
        gradientView = UIView(frame: CGRect(x: -30, y: 0, width: 100, height: 60))
        logo.addSubview(gradientView)
        gradientView.layer.insertSublayer(gradientColor(frame: gradientView.bounds), at: 0)
        gradientView.backgroundColor = UIColor.clear
    }
    
    fileprivate func gradientColor(frame: CGRect) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = frame
        layer.startPoint = CGPoint(x: 0.5, y: 0.5)
        layer.endPoint = CGPoint(x: 0, y: 0.5)
        layer.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.withAlphaComponent(0.7).cgColor, UIColor.white.withAlphaComponent(0).cgColor]
        return layer
    }
    
    func setupUI() {
        indicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)), type: .lineScale)
        addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(20)
        }

    }
    
    func startAnimation() {
        logo.isHidden = true
        indicator.startAnimating()
//        initializeGradientView()
//        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.autoreverse, .repeat], animations: {
//            self.gradientView.frame.origin.x = 100
//        }, completion: nil)
    }
    
    func stopAnimation() {
        indicator.stopAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.logo.isHidden = false
        }
//        gradientView.layer.removeAllAnimations()
//        gradientView = nil
    }
}
