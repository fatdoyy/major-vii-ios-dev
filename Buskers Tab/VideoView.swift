//
//  VideoView.swift
//  major-7-ios
//
//  Created by jason on 11/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import PIPKit
import AVKit
import WebKit

class VideoView: AVPlayerViewController, PIPUsable, WKUIDelegate {
    
    var initialState: PIPState { return .pip }
    let width: CGFloat = UIScreen.main.bounds.width * 0.7
    var pipSize: CGSize { return CGSize(width: width, height: width / (16 / 9)) }
    
    var webView: WKWebView!
    
//    override func loadView() {
//        let webConfiguration = WKWebViewConfiguration()
//        webConfiguration.allowsInlineMediaPlayback = true
//        webView = WKWebView(frame: .zero, configuration: webConfiguration)
//        webView.uiDelegate = self
//
//        view = webView
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.cornerRadius = GlobalCornerRadius.value / 2
        view.clipsToBounds = true
        
//        let myURL = URL(string:"https://www.youtube.com/embed/NdLZ76bYNy8")
//        let myRequest = URLRequest(url: myURL!)
//        webView.load(myRequest)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        showsPlaybackControls = true
    }
    
    /*override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if PIPKit.isPIP {
            stopPIPMode()
        } else {
            startPIPMode()
        }
    }*/
    
    func didChangedState(_ state: PIPState) {
        switch state {
        case .pip:
            print("PIPViewController.pip")
        case .full:
            print("PIPViewController.full")
        }
    }
    
    
}

extension AVPlayerViewController: AVPlayerViewControllerDelegate {
    
}
