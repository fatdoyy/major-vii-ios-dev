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

extension Dictionary where Value: Equatable { //return all possible keys with same value
    func allKeys(forValue val: Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
}

extension Dictionary where Value: Equatable { //return ONE key only, so it means the Dictionary in this case is 1:1 (i.e won't have same values for different keys)
    func uniqueKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}

//check if array is identical
extension Array where Element: Comparable {
    func isIdentical(to other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
