//
//  Network.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 26/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

protocol RoomConnection {
    var roomMasterId: String { get }

    static func getConnection(for room: FirestoreRoom,
                              removed removedCallback: @escaping () -> Void,
                              completion callback: @escaping (RoomConnection?, Error?) -> ())
    func join(removed removedCallback: @escaping () -> Void,
              completion callback: @escaping (RoomConnection?, Error?) -> ())

    func startGame(initialState: GameState, background: Data, completion callback: @escaping (Error?) -> Void) throws

    func push(currentState: GameState, completion callback: @escaping (Error?) -> Void) throws

    func subscribeToActions(for turn: Int, callback: @escaping ([(String, [PlayerAction])], Error?) -> Void)

    func subscribeToMembers(with callback: @escaping ([RoomMember]) -> Void)

    func push(actions: [PlayerAction], fromPlayer player: GenericPlayer,
              forTurnNumbered turn: Int,
              completion callback: @escaping (Error?) -> ()) throws

    func checkTurnEnd(actions: [Map], forTurnNumbered turn: Int) throws

    func set(teams: [Team])

    func subscibeToTeamNames(with callback: @escaping ([String]) -> Void)

    func subscribeToStart(with callback: @escaping (GameState, Data) -> Void)

    func changeTeamName(for identifier: String, to teamName: String)

    func remove(player: String)
}
