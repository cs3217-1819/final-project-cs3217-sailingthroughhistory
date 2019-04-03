//
//  GameState.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class GameState: GenericGameState {
    var gameTime: GameTime
    var gameObjects: [GameObject] {
        return map.gameObjects
    }
    var itemParameters = [ItemParameter]()

    private(set) var map: Map
    private var teams = [Team]()
    private var players = [GenericPlayer]()
    private var speedMultiplier = 1.0

    private var playerTurnOrder = [GenericPlayer]()

    init(baseYear: Int, level: GenericLevel, players: [WaitingRoomPlayer]) {
        //TODO
        gameTime = GameTime()
        teams = level.teams
        //initializePlayersFromParameters(parameters: level.playerParameters)
        map = level.map
        itemParameters = level.itemParameters
        initializePlayers(from: level.playerParameters, for: players)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try gameTime = values.decode(GameTime.self, forKey: .gameTime)
        try map = values.decode(Map.self, forKey: .map)
        try itemParameters = values.decode([ItemParameter].self, forKey: .itemParameters)
        try teams = values.decode([Team].self, forKey: .teams)
        try players = values.decode([Player].self, forKey: .players)
        try speedMultiplier = values.decode(Double.self, forKey: .speedMultiplier)

        for player in players {
            player.addShipsToMap(map: map)
        }
        for node in map.getNodes() {
            guard let port = node as? Port else {
                continue
            }
            port.assignOwner(teams.first(where: { team in
                team.name == port.ownerName
            }))
        }
    }

    func encode(to encoder: Encoder) throws {
        guard let players = players as? [Player] else {
            return
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(gameTime, forKey: .gameTime)
        try container.encode(map, forKey: .map)
        try container.encode(itemParameters, forKey: .itemParameters)
        try container.encode(teams, forKey: .teams)
        try container.encode(players, forKey: .players)
        try container.encode(speedMultiplier, forKey: .speedMultiplier)
    }

    private enum CodingKeys: String, CodingKey {
        case gameTime
        case map
        case itemParameters
        case teams
        case players
        case speedMultiplier
    }

    func getPlayers() -> [GenericPlayer] {
        return players
    }

    func getNextPlayer() -> GenericPlayer? {
        let nextPlayer = playerTurnOrder.removeFirst()
        nextPlayer.startTurn(speedMultiplier: speedMultiplier, map: map)
        return nextPlayer
    }

    func startNextTurn(speedMultiplier: Double) {
        self.speedMultiplier = speedMultiplier
        playerTurnOrder.removeAll()
        for player in players {
            playerTurnOrder.append(player)
        }
    }

    func endGame() {
    }

    private func initializePlayers(from parameters: [PlayerParameter], for roomPlayers: [WaitingRoomPlayer]) {
        players.removeAll()
        for roomPlayer in roomPlayers {
            let parameter = parameters.first {
                $0.getTeam().name == roomPlayer.teamName
            }
            print(parameters.map{ $0.getTeam().name })
            guard let unwrappedParam = parameter, roomPlayer.hasTeam else {
                preconditionFailure("Player has invalid team.")
            }

            let node: Node

            if let startingNode = unwrappedParam.getStartingNode() {
                node = startingNode
            } else {
                guard let defaultNode = map.getNodes().first else {
                    fatalError("No nodes to start from")
                }

                node = defaultNode
            }

            let team = unwrappedParam.getTeam()
            if !teams.contains(where: {$0.name == team.name}) {
                teams.append(team)
            }
            players.append(Player(name: roomPlayer.playerName, team: team, map: map, node: node, deviceId: roomPlayer.deviceId))
        }
    }
}
