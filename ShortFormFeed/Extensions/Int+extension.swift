//
//  Int+extension.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/20.
//

import Foundation

extension Int {
    public func toK() -> String {
        if self >= 1000 {
            let str = String(self)
            let startIndex = str.index(str.startIndex, offsetBy: 0)
            let endIndex = str.index(str.startIndex, offsetBy: 1)
            return str[startIndex..<endIndex].description + "K"
        }

        return self.description
    }
}
