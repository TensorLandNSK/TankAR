//
//  GameManager.swift
//  TanksAR
//
//  Created by tensor_guest on 20/04/2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import ARKit

class GameManager : TankServiceDelegate {
    public var delegate : GameManagerDelegate?
    var worldMapURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("worldMapURL")
        } catch {
            fatalError("Error getting world map URL from document directory.")
        }
    }()
    
    func archive(worldMap: ARWorldMap) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
        try data.write(to: self.worldMapURL, options: [.atomic])
    }
    
    func unarchive(worldMapData data: Data) -> ARWorldMap? {
        guard let unarchievedObject = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data),
            let worldMap = unarchievedObject else { return nil }
        return worldMap
    }
    
    func retrieveWorldMapData(from url: URL) -> Data? {
        do {
            return try Data(contentsOf: self.worldMapURL)
        } catch {
            fatalError("Error retrieving world map data.")
        }
    }
    
    func sendWorld(worldMap: ARWorldMap) {
        do {
            try archive(worldMap: worldMap)
            TanksService.shared().sendData(url: worldMapURL)
        } catch {
            print(error)
        }
    }
    
    func didDataReceived(data : Data, fromPeer peerID : MCPeerID) {
        let decoder = JSONDecoder()
        let gameData = try! decoder.decode(GameData.self, from: data)
        switch gameData {
        case .gameBoard(let url):
            let worldMap = self.retrieveWorldMapData(from: url)
            let mapUnarchived = self.unarchive(worldMapData: worldMap!)
            delegate?.didWorldReceieved(worldMap: mapUnarchived!)
        }
    }
}
