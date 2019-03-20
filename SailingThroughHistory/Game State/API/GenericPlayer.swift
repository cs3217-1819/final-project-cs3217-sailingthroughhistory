//
//  GenericPlayer.swift
//  SailingThroughHistory
//
//  Created by henry on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol GenericPlayer {
    var name: String { get }
    var money: GameVariable<Int> { get }
    var state: GameVariable<PlayerState> { get }
    var interface: Interface? { get set }

    init(name: String, node: Node)

    // Before moving
    func startTurn()
    func buyUpgrade(upgrade: Upgrade)
    func getOwnedPorts() -> [Port]
    func setTax(port: Port, amount: Int)

    // Moving - Auto progress to End turn if cannot dock
    func move(node: Node)
    func getNodesInRange(roll: Int) -> [Node]

    // After moving can choose to dock
    func canDock() -> Bool
    func dock()

    // Docked - End turn is manual here
    func getPurchasableItemTypes() -> [ItemParameter]
    func getMaxPurchaseAmount(itemType: ItemParameter) -> Int
    func buy(itemType: ItemParameter, quantity: Int)
    func sell(item: GenericItem)

    // End turn - supplies are removed here
    func endTurn()
}

func == (lhs: GenericPlayer, rhs: GenericPlayer?) -> Bool {
    return lhs.name == rhs?.name
}

func != (lhs: GenericPlayer, rhs: GenericPlayer?) -> Bool {
    return !(lhs == rhs)
}
