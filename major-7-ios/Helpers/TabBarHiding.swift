//
//  TabBarHiding.swift
//  major-7-ios
//
//  Created by jason on 13/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class TabBar {
    
    static func hide(rootView: UIViewController){
        var frame = rootView.tabBarController?.tabBar.frame
        if frame?.minY != rootView.view.frame.maxY {
            let newY = UIScreen.main.bounds.height + (frame?.size.height)!
            frame?.origin.y = newY
            UIView.animate(withDuration: 0.5, animations: {
                rootView.tabBarController?.tabBar.frame = frame!
            })
        }
    }
    
    static func show(rootView: UIViewController){
        var frame = rootView.tabBarController?.tabBar.frame
        let newY = UIScreen.main.bounds.height - (frame?.size.height)!
        let originY = (frame?.minY)! - (frame?.height)!
        if frame?.minY != rootView.view.frame.maxY {
            
            frame?.origin.y = newY
            UIView.animate(withDuration: 0.5, animations: {
                rootView.tabBarController?.tabBar.frame = frame!
            })
            
        } else{
            frame?.origin.y = originY
            // print(frame?.origin.y)
            print("frame resetted")
        }
    }
}
