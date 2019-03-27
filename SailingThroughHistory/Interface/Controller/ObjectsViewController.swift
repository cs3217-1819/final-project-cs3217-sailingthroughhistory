//
//  ObjectsViewController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 21/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

struct ObjectsViewController {
    private var views = [ObjectIdentifier: UIGameObjectImageView]()
    private let mainController: MainGameViewController
    private let view: UIView

    init(view: UIView, mainController: MainGameViewController) {
        self.view = view
        self.mainController = mainController
    }

    func getFrame(for object: ReadOnlyGameObject) -> CGRect? {
        return views[ObjectIdentifier(object)]?.frame
    }

    func onTap(objectView: UIGameObjectImageView) {
        if objectView.tapCallback != nil,
            objectView.object as? Node != nil {
                onTapChoosableNode(nodeView: objectView)
                return
        }

        if objectView.object as? Port != nil {
            onTapPort(portView: objectView)
            return
        }
    }

    private func onTapChoosableNode(nodeView: UIGameObjectImageView) {
        guard nodeView.tapCallback != nil,
            nodeView.object as? Node != nil else {
            return
        }

        nodeView.callTapCallback()

        // Remove glow/callback from nodes.
        views.values
            .filter { $0.object as? Node != nil }
            .forEach {
                $0.removeGlow()
                $0.tapCallback = nil
        }
    }

    private func onTapPort(portView: UIGameObjectImageView) {
        guard let port = portView.object as? Port else {
            return
        }

        mainController.showInformation(ofPort: port)
    }

    mutating func add(object: ReadOnlyGameObject, at frame: Rect, withDuration duration: TimeInterval,
                      callback: @escaping () -> Void) {
        let objectIdentifier = ObjectIdentifier(object)
        views[objectIdentifier]?.removeFromSuperview()
        let image = UIImage(named: object.image)
        let view = UIGameObjectImageView(image: image, object: object)
        if object.isAnimated {
            view.animationImages = object.images
                .rotatedLeft(
                    by: UInt(object.startingFrame))
                .compactMap { UIImage(named: $0 )}
            view.animationDuration = object.loopDuration
            view.startAnimating()
        }
        views[objectIdentifier] = view
        view.alpha = 0
        self.view.addSubview(view)
        view.frame = CGRect.translatingFrom(otherBounds: mainController.interfaceBounds,
                                            otherFrame: CGRect(fromRect: frame), to: self.view.bounds)
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 1
        }, completion: { _ in callback() })
    }

    mutating func remove(object: ReadOnlyGameObject, withDuration duration: TimeInterval, callback: @escaping () -> Void) {
        guard let view = views.removeValue(forKey: ObjectIdentifier(object)) else {
            callback()
            return
        }

        view.fadeOutAndRemove(withDuration: duration, completion: callback)
    }

    func makeChoosable(nodes: [Node], withDuration duration: TimeInterval, tapCallback: @escaping (ReadOnlyGameObject) -> Void, callback: @escaping () -> Void) {
        if nodes.isEmpty {
            callback()
            return
        }

        let views = self.views

        for node in nodes {
            let nodeKey = ObjectIdentifier(node)
            views[nodeKey]?.isUserInteractionEnabled = true
            views[nodeKey]?.tapCallback = tapCallback
        }

        UIView.animate(withDuration: duration, animations: {
            nodes.forEach {
                views[ObjectIdentifier($0)]?.addGlow(colored: .purple)
            }
        }, completion: { _ in
            callback()
        })
    }

    func move(object: ReadOnlyGameObject, to dest: Rect, withDuration duration: TimeInterval,
              callback: @escaping () -> Void) {
        guard let objectView = views[ObjectIdentifier(object)] else {
            return
        }

        let mainController = self.mainController
        let bounds = view.bounds

        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
            objectView.frame = CGRect.translatingFrom(otherBounds: mainController.interfaceBounds,
                                                      otherFrame: CGRect(fromRect: dest),
                                                      to: bounds)
            }, completion: { _ in callback() })
    }
}