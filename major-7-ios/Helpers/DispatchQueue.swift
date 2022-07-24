//
//  DispatchQueue.swift
//  major-7-ios
//
//  Created by jason on 28/8/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

extension DispatchQueue {
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}
