//
//  Item.swift
//  OWUI
//
//  Created by Ben Smith on 28/06/2025.
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
