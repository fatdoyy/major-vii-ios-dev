//
//  TabBarHiding.swift
//  major-7-ios
//
//  Created by jason on 13/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class TabBar {
    
    static func hide(from: UIViewController) {
        var frame = from.tabBarController?.tabBar.frame
        if frame?.minY != from.view.frame.maxY {
            let newY = UIScreen.main.bounds.height + (frame?.size.height)!
            frame?.origin.y = newY
            UIView.animate(withDuration: 0.5, animations: {
                from.tabBarController?.tabBar.frame = frame!
            })
        }
    }
    
    static func show(from: UIViewController) {
        var frame = from.tabBarController?.tabBar.frame
        let newY = UIScreen.main.bounds.height - (frame?.size.height)!
        let originY = (frame?.minY)! - (frame?.height)!
        if frame?.minY != from.view.frame.maxY {
            
            frame?.origin.y = newY
            UIView.animate(withDuration: 0.5, animations: {
                from.tabBarController?.tabBar.frame = frame!
            })
            
        } else {
            frame?.origin.y = originY
            // print(frame?.origin.y)
            print("frame resetted")
        }
    }
    
    static func toggle(from: UIViewController, hidden: Bool, animated: Bool) {
        let tabBar = from.tabBarController?.tabBar
        let offset = (hidden ? UIScreen.main.bounds.size.height : UIScreen.main.bounds.size.height - (tabBar?.frame.size.height)! )
        if offset == tabBar?.frame.origin.y { return }
        //print("Changing tab bar origin y position...")
        
        let duration: TimeInterval = (animated ? 0.4 : 0.0)
        UIView.animate(withDuration: duration,
                       animations: {tabBar!.frame.origin.y = offset},
                       completion:nil)
    }
}
