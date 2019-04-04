//
//  MainGameViewController+TableViewDelegate.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class PortItemTableDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    private static let reuseIdentifier: String = "itemsTableCell"
    private static let defaultPrice: Int = 100
    private static let buyButtonLabel = "Buy"
    private static let sellButtonLabel = "Sell"
    private static let boughtSection = 0
    private static let soldSection = 1
    private static let numSections = 2
    private let mainController: MainGameViewController
    private var playerCanInteract = false
    private var selectedPort: Port?
    private var itemTypesSoldByPort = [ItemType]()
    private var itemTypesBoughtByPort = [ItemType]()

    init(mainController: MainGameViewController) {
        self.mainController = mainController
    }

    func didSelect(port: Port, playerCanInteract: Bool) {
        self.itemTypesSoldByPort = port.itemParametersSoldByPort
        self.playerCanInteract = playerCanInteract
        self.selectedPort = port
        // TODO: Update when bought array is added.
        //self.itemsBought = port.itemParametersBought
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: PortItemTableDataSource.reuseIdentifier, for: indexPath)
            as? UIPortItemTableCell

        guard let tableCell = cell else {
            preconditionFailure("Cell does not inherit from UIPortItemTableCell.")
        }

        guard let port = selectedPort else {
            return tableCell
        }

        var array: [ItemType]
        switch indexPath.section {
        case PortItemTableDataSource.boughtSection:
            array = itemTypesBoughtByPort
            let item = array[indexPath.row]
            tableCell.set(price: port.getSellValue(of: item) ??
                PortItemTableDataSource.defaultPrice)
            tableCell.set(buttonLabel: PortItemTableDataSource.sellButtonLabel)
            tableCell.buttonPressedCallback = { [weak self] in
                self?.mainController.portItemButtonPressed(action: .playerSell(item: item))
            }
        case PortItemTableDataSource.soldSection:
            array = itemTypesSoldByPort
            let item = array[indexPath.row]
            tableCell.set(price: port.getBuyValue(of: array[indexPath.row]) ??
                PortItemTableDataSource.defaultPrice)
            tableCell.set(buttonLabel: PortItemTableDataSource.buyButtonLabel)
            tableCell.buttonPressedCallback = { [weak self] in
                self?.mainController.portItemButtonPressed(action: .playerBuy(item: item))
            }
        default:
            array = []
        }

        tableCell.set(name: array[indexPath.row].rawValue)
        if playerCanInteract {
            tableCell.enable()
        } else {
            tableCell.disable()
        }

        return tableCell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return PortItemTableDataSource.numSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case PortItemTableDataSource.boughtSection:
            return itemTypesBoughtByPort.count
        case PortItemTableDataSource.soldSection:
            return itemTypesSoldByPort.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case PortItemTableDataSource.boughtSection:
            return "Buying"
        case PortItemTableDataSource.soldSection:
            return "Selling"
        default:
            return nil
        }
    }
}
