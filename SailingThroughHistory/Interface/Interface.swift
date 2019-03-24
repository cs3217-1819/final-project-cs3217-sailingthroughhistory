//
//  Interface.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 15/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import RxSwift
import UIKit

class Interface {
    let bounds: CGRect
    let background: String = "worldmap1815.png"
    let events = InterfacePublishSubject<InterfaceEvents>()
    let monthSymbols = Calendar.current.monthSymbols
    let players: [GenericPlayer]
    private(set) var pendingEvents = [InterfaceEvent]()
    private(set) var objectFrames = [GameObject: CGRect]()
    private(set) var paths = ObjectPaths()
    private(set) var currentTurnOwner: GenericPlayer?

    init(players: [Player], bounds: CGRect) {
        self.players = players
        self.bounds = bounds
    }

    /// TODO: DELETE THESE
    /// Add a pending operation to add the given object to the interface. Once commited/broadcasted, rhe frame of the
    /// object in the interface will be its frame at the time this add function is called.
    ///
    /// - Parameter object: The `GameObject` to add.
    @available(*, deprecated, message: "Use InterfaceDrawable")
    func add(object: GameObject) {
        pendingEvents.append(.addObject(object, atFrame: object.frame))
    }

    /// Add a pending operation to add the given object to the interface. Once commited/broadcasted, the path will be
    /// drawn from and to the two `GameObject`'s current frame (on broadcast).
    ///
    /// - Parameter path: The `Path` to be drawn.
    @available(*, deprecated, message: "Use InterfacePath")
    func add(path: Path) {
        pendingEvents.append(.addPath(path))
    }

    /// Add a pending operation to remove the `GameObject`
    ///
    /// - Parameter object: The `GameObject` to remove.
    @available(*, deprecated, message: "Use InterfaceDrawable")
    func remove(object: GameObject) {
        pendingEvents.append(.removeObject(object))
    }

    /// Add a pending operation to remove a `Path`.
    ///
    /// - Parameter path: The `Path` to remove.
    @available(*, deprecated, message: "Use InterfacePath")
    func remove(path: Path) {
        pendingEvents.append(.removePath(path))
    }

    /// Add a pending operation to add the given drawable to the interface.
    ///
    /// - Parameter drawable: The `InterfaceDrawable` to add.
    func drawable(drawable: InterfaceDrawable) {
        pendingEvents.append(.addDrawable(drawable))
    }

    /// Add a pending operation to add the given path to the interface.
    ///
    /// - Parameter path: The `InterfacePath` to be drawn.
    func add(path: InterfacePath) {
        pendingEvents.append(.addInterfacePath(path))
    }

    /// Add a pending operation to remove the `GameObject`
    ///
    /// - Parameter drawable: The `InterfaceDrawable` to remove.
    func remove(drawable: InterfaceDrawable) {
        pendingEvents.append(.removeDrawable(drawable))
    }

    /// Add a pending operation to remove a `InterfacePath`.
    ///
    /// - Parameter path: The `InterfacePath` to remove.
    func remove(path: InterfacePath) {
        pendingEvents.append(.removeInterfacePath(path))
    }

    /// Add a pending operation to update the position of the drawable with the given id to the given frame on the
    /// interface. Nothing happens if no drawable in the interface matches the id.
    ///
    /// - Parameters:
    ///   - drawableId: The unique id of the drawable to move
    ///   - frame: The new frame of the drawable
    func updatePositionOfDrawable(withId drawableId: Int, to frame: Rect) {
        pendingEvents.append(.moveDrawable(withId: drawableId, toFrame: frame))
    }

    /// Add a pending operation to update the position of given object to the interface. Once commited/broadcasted,
    /// the frame of the object in the interface will be its frame at the time this updatePosition function is called.
    ///
    /// - Parameter object: The `GameObject` to add.
    @available(*, deprecated, message: "Use InterfaceDrawable")
    func updatePosition(of object: GameObject) {
        pendingEvents.append(.move(object, toFrame: object.frame))
    }

    /// Add a pending operation to update the month displayed on the interface. Months are indexed from 0-11 (inclusive)
    ///
    /// - Parameter newMonth: The index of the new month.
    func changeMonth(to newMonth: Int) {
        if !monthSymbols.indices.contains(newMonth) {
            preconditionFailure("\(newMonth) is not a valid month.")
        }
        pendingEvents.append(.changeMonth(toMonth: monthSymbols[newMonth]))
    }

    /// Add a pending operation to pause and show an alert with the given title and msg. Event batches
    /// commited/broadcasted after this operation will not be executed until this alert is dismissed by the user.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - msg: The description of the alert.
    func pauseAndShowAlert(titled title: String, withMsg msg: String) {
        pendingEvents.append(.pauseAndShowAlert(titled: title, withMsg: msg))
    }

    /// Add a pending operation to start the input player's turn on the interface. A countdown timer will be shown if
    /// timeLimit is not nil. This timer starts from the time the user dismisses the alert notifying them of this event.
    ///
    /// - Parameters:
    ///   - player: The `Player` "owner" of the turn.
    ///   - timeLimit: The time limit (in seconds).
    ///   - timeOutCallback: Called when the time limit is reached.
    func playerTurnStart(player: GenericPlayer, timeLimit: TimeInterval?, timeOutCallback: @escaping () -> Void) {
        pendingEvents.append(.playerTurnStart(player: player, timeLimit: timeLimit, timeOutCallback: timeOutCallback))
    }

    /// Add a pending operation to highlight the given nodes and allow the user to tap on them. Once tapped,
    /// selectCallback will be called with the tapped node being the parameter.
    ///
    /// - Parameters:
    ///   - nodes: The nodes to be available for selection.
    ///   - selectCallback: Function to be called when a node is selected.
    func showTravelChoices(_ nodes: [Node], selectCallback: @escaping (GameObject) -> Void) {
        pendingEvents.append(.showTravelChoices(choices: nodes, selectCallback: selectCallback))
    }

    /// TODO: Change method name to commit and broadcast
    /// Commits all pending operations and broadcasts all pending operations to any observers. All pending operations
    /// will be animated simultaneously with the same duration and pending operations from future calls of this function
    /// will be blocked until the animations have been completed.
    ///
    /// - Parameter duration: The duration of the animations for the pending operations.
    func broadcastInterfaceChanges(withDuration duration: TimeInterval) {
        var validEvents = [InterfaceEvent]()
        for event in pendingEvents {
            switch event {
            case .addPath(let path):
                if !addPathToState(path: path) {
                    continue
                }
            case .addObject(let object, let frame):
                objectFrames[object] = frame
            case .move(let object, let frame):
                if objectFrames[object] == nil {
                    continue
                }

                objectFrames[object] = frame
            case .removePath(let path):
                paths.remove(path: path)
            case .removeObject(let object):
                objectFrames[object] = nil
                paths.removeAllPathsAssociated(with: object)
            case .playerTurnStart(let player, _, _):
                currentTurnOwner = player
            case .playerTurnEnd:
                currentTurnOwner = nil
            default:
                break
            }

            validEvents.append(event)
        }

        let toBroadcast = InterfaceEvents(events: validEvents, duration: duration)
        pendingEvents = []
        events.on(next: toBroadcast)
    }

    /// Subscribes to this Interface. The callback will be called when `InterfaceEvents` are broadcasted.
    ///
    /// - Parameter callback: Called when `InterfaceEvents` are broadcasted as the parameter.
    func subscribe(callback: @escaping (Event<InterfaceEvents>) -> Void) {
        return events.subscribe(callback: callback)
    }

    /// Add a pending operation to end the player turn
    func endPlayerTurn() {
        pendingEvents.append(.playerTurnEnd)
    }

    private func addPathToState(path: Path) -> Bool {
        if objectFrames[path.fromObject] == nil || objectFrames[path.toObject] == nil {
            return false
        }

        paths.add(path: path)

        return true
    }
}
