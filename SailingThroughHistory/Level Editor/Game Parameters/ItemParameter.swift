//
//  Items.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class ItemParameter {
    let displayName: String
    let weight: Int
    public let itemType: ItemType

    private let isConsumable: Bool
    private var sellValues = [Port: Int]()
    private var buyValues = [Port: Int]()

    required public init(itemType: ItemType, displayName: String, weight: Int, isConsumable: Bool) {
        self.itemType = itemType
        self.displayName = displayName
        self.weight = weight
        self.isConsumable = isConsumable
    }
    
    // Create a quantized representation
    
    func createItem(quantity: Int) -> GenericItem {
        return Item(itemType: self, quantity: quantity)
    }
    
    // Global pricing information
    
    func getBuyValue(at port: Port) -> Int? {
        return buyValues[port]
    }
    
    func getSellValue(at port: Port) -> Int? {
        return sellValues[port]
    }

    func setBuyValue(at port: Port, value: Int) {
        if getBuyValue(at: port) == nil {
            port.itemTypes.append(self)
        }
        buyValues[port] = value
    }
    
    func setSellValue(at port: Port, value: Int) {
        sellValues[port] = value
    }
    
    // Availability at ports
    
    func delete(from port: Port) {
        guard let index = port.itemTypes.firstIndex(where: { $0 == self }) else {
            return
        }
        port.itemTypes.remove(at: index)
        buyValues.removeValue(forKey: port)
        sellValues.removeValue(forKey: port)
    }
}

extension ItemParameter: Equatable {
    static func == (lhs: ItemParameter, rhs: ItemParameter) -> Bool {
        return lhs.itemType == rhs.itemType
    }
}
