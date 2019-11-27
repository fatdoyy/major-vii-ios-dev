//
//  InAppNotifications.swift
//  major-7-ios
//
//  Created by jason on 30/7/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import SwiftMessages

class InAppNotifications {}

//MARK: - Warning messages
extension InAppNotifications {
    static func loginWarning() -> UIView {
        let loginMsgView = MessageView.viewFromNib(layout: .cardView)

        // Theme message elements with the warning style.
        loginMsgView.configureTheme(.warning)
        
        // Add a drop shadow.
        loginMsgView.configureDropShadow()
        
        // Set message title, body, and icon. Here, we're overriding the default warning
        // image with an emoji character.
        let iconText = "🤔"
        loginMsgView.configureContent(title: "Oh-no!", body: "Please login first", iconText: iconText)
        
        loginMsgView.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        loginMsgView.button?.setTitle("Login", for: .normal)
        loginMsgView.button?.addTarget(self, action: #selector(showLoginVC), for: .touchUpInside)
        
        // Increase the external margin around the card. In general, the effect of this setting
        // depends on how the given layout is constrained to the layout margins.
        loginMsgView.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        // Reduce the corner radius (applicable to layouts featuring rounded corners).
        (loginMsgView.backgroundView as? CornerRoundingView)?.cornerRadius = GlobalCornerRadius.value
        
        return loginMsgView
    }
    
    @objc static func showLoginVC(_ sender: UIButton) {
        Animations.btnBounce(sender: sender)
        NotificationCenter.default.post(name: .showLoginVC, object: nil)
    }
    
    static func offlineWarning() -> UIView {
        let msg = MessageView.viewFromNib(layout: .statusLine)
        msg.configureTheme(.error)
        
        //layout fix
        if !UIDevice.current.hasHomeButton {
            msg.layoutMarginAdditions.top = -16
        }
        
        msg.bodyLabel?.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        msg.configureContent(body: "Offline")
        
        return msg
    }
}

//MARK: - SwiftMessages configs
extension InAppNotifications {
    static func foreverDurationConfig() -> SwiftMessages.Config {
        var config = SwiftMessages.Config()
        
        // Display in a window at the specified window level: UIWindow.Level.statusBar
        // displays over the status bar while UIWindow.Level.normal displays under.
        config.presentationContext = .window(windowLevel: .statusBar)

        // Disable the default auto-hiding behavior.
        config.duration = .forever

        // Disable the interactive pan-to-hide gesture.
        config.interactiveHide = false

        // Specify a status bar style to if the message is displayed directly under the status bar.
        config.preferredStatusBarStyle = .lightContent
        
        return config
    }
}
