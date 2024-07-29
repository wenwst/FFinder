//
//  Item.swift
//  FFinder
//
//  Created by wst on 2024/7/29.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
