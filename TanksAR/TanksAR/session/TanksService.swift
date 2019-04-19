//
//  TanksService.swift
//  TanksAR
//
//  Created by tensor_guest on 19/04/2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class TanksService: NSObject {
    private let serviceType = "tanks-service"
    
    private let maxPeersAmount = 1
    
    private var serviceSession : MCSession!
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    
    private var peersList : [MCPeerID] = []
    
    private let serviceAdvertiser : MCAdvertiserAssistant
    
    private static var sharedService : TanksService = {
        let tanksService = TanksService()
        return tanksService
    }()
    
    private override init() {
        self.serviceSession = MCSession(peer: myPeerId)
        self.serviceAdvertiser = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: serviceSession)
        super.init()
        
        //self.serviceAdvertiser.startAdvertisingPeer()
    }
    
    /*
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
    }
     */
    
    class func shared() -> TanksService {
        return sharedService
    }
    
    public func makeBrowserViewController() -> MCBrowserViewController {
        return MCBrowserViewController(serviceType: serviceType, session: self.serviceSession)
    }
    
    public func startAdvertising() {
        self.serviceAdvertiser.start()
    }
    
    private func stopAdvertising() {
        self.serviceAdvertiser.stop()
    }
    
    public func sendData(data: Data) {
        if self.peersList.count > 0 {
            do {
                try serviceSession.send(data, toPeers: self.peersList, with: .reliable)
            } catch {
                print(error)
            }
        }
    }
}

extension TanksService : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
        if state == MCSessionState.connecting {
            if self.peersList.count >= maxPeersAmount {
                stopAdvertising()
                NotificationCenter.default.post(name: Notification.Name.peerDeclined, object: nil)
            } else {
                self.peersList.append(peerID)
                NotificationCenter.default.post(name: Notification.Name.peerConnecting, object: nil)
            }
        } else if state == MCSessionState.notConnected {
            if let peerIdx = self.peersList.firstIndex ( where: { (peer) -> Bool in
                return peerID.isEqual(peer)
                })
            {
                self.peersList.remove(at: peerIdx)
                NotificationCenter.default.post(name: Notification.Name.peerDisconnected, object: nil)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let jsonDecoder = JSONDecoder()
       // try jsonDecoder.decode(, from: )
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
}
