//
//  Notifications.swift
//  TanksAR
//
//  Created by tensor_guest on 19/04/2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let peerConnecting = Notification.Name("peerConnecting")
    static let peerDisconnected = Notification.Name("peerDisconnected")
    static let peerDeclined = Notification.Name("peerDeclined")
}
