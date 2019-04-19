//
//  DetailEditTable.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class DetailEditTableViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var data = [[GameParameterItem]]()
    var numOfTurnMsg = "Number of Turn: "
    var timeLimitMsg = "Time Limit Per Turn (sec): "

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        self.navigationController?.isToolbarHidden = false
    }

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func confirmPressed(_ sender: Any) {
        for cell in tableView.visibleCells {
            guard let indexPath = tableView.indexPath(for: cell) else {
                continue
            }

            switch data[indexPath.section][indexPath.item].type {
            case .player:
                guard let castedCell = cell as? PlayerTableViewCell,
                    let item = castedCell.item as? PlayerParameterItem else {
                    continue
                }
                if let name = castedCell.nameField.text,
                    let moneyText = castedCell.moneyField.text {
                    item.playerParameter.set(name: name, money: Int(moneyText))
                }
            case .turn:
                guard let castedCell = cell as? TurnTableViewCell,
                    let item = castedCell.item as? TurnParameterItem else {
                    continue
                }

                guard let inputText = castedCell.textField.text else {
                    continue
                }

                guard let input = Int(inputText) else {
                    continue
                }

                switch castedCell.label.text {
                case numOfTurnMsg:
                    item.game.numOfTurn = input
                case timeLimitMsg:
                    item.game.timeLimit = input
                default:
                    continue
                }
            }

        }
        self.dismiss(animated: true, completion: nil)
    }

    func initWith(game: GameParameter) {
        self.data.append(game.playerParameters.map {
            PlayerParameterItem(playerParameter: $0)
        })
        self.data.append([TurnParameterItem(label: numOfTurnMsg, game: game, input: game.numOfTurn),
                          TurnParameterItem(label: timeLimitMsg, game: game, input: game.timeLimit)])
    }
}