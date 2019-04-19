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
    
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    
    private static var sharedService : TanksService = {
        let tanksService = TanksService()
        return tanksService
    }()
    
    private override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        self.serviceSession = MCSession(peer: myPeerId)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
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
        self.serviceAdvertiser.startAdvertisingPeer()
    }
    
    private func stopAdvertising() {
        self.serviceAdvertiser.stopAdvertisingPeer()
    }
    
    
}

extension TanksService : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
    }
    
}

extension TanksService : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
        if  state == MCSessionState.connecting {
            if self.peersList.count >= maxPeersAmount {
                stopAdvertising()
            } else {
                self.peersList.append(peerID)
            }
        } else if state == MCSessionState.notConnected {
            if let peerIdx = self.peersList.firstIndex ( where: { (peer) -> Bool in
                return peerID.isEqual(peer)
                })
            {
                self.peersList.remove(at: peerIdx)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
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
