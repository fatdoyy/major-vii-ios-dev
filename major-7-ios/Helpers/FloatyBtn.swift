//
//  FloatyButton.swift
//  major-7-ios
//
//  Created by jason on 12/12/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import Floaty

class FloatyBtn {
    
    static func create(btn: Floaty, toVC: UIViewController) {
        let walletItem = FloatyItem()
        walletItem.hasShadow = true
        walletItem.buttonColor = .mintGreen()
        walletItem.titleShadowColor = UIColor.darkGray
        walletItem.circleShadowColor = UIColor.black
        walletItem.title = "Add to Apple Wallet"
        walletItem.imageSize = CGSize(width: 40, height: 40)
        walletItem.icon = UIImage(named: "icon_apple_wallet")
        walletItem.handler = { item in
            //handle tapped action
        }
        
        let reminderItem = FloatyItem()
        reminderItem.hasShadow = true
        reminderItem.buttonColor = .mintGreen()
        reminderItem.titleShadowColor = UIColor.darkGray
        reminderItem.circleShadowColor = UIColor.black
        reminderItem.title = "Remind Me!"
        reminderItem.imageSize = CGSize(width: 44, height: 44)
        reminderItem.icon = UIImage(named: "icon_reminder")
        reminderItem.handler = { item in
            //handle tapped action
        }
        
        btn.addItem(item: reminderItem)
        btn.addItem(item: walletItem)
        
        btn.itemSize = 48
        btn.paddingX = 24
        btn.buttonImage = UIImage(named: "eventdetails_menu")
        btn.overlayColor = UIColor.black.withAlphaComponent(0.7)
        btn.buttonColor = .clear
        btn.sticky = true
        
        toVC.view.addSubview(btn)
        
    }
}

