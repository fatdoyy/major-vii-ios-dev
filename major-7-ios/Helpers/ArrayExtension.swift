//
//  ArrayExtension.swift
//  major-7-ios
//
//  Created by jason on 19/1/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
