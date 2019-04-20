//
//  TankServiceDelegate.swift
//  TanksAR
//
//  Created by tensor_guest on 20/04/2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol TankServiceDelegate {
    func didDataReceived(data : Data, fromPeer peerID : MCPeerID)
    func didDataReceived(url : URL, fromPeer peerID : MCPeerID)
}
