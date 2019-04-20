//
//  GameManager.swift
//  TanksAR
//
//  Created by tensor_guest on 19/04/2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import Foundation
import CoreGraphics

enum GameData {
    case gameBoard(value: URL)
    case tankMovement(vector: CGPoint)
    case barrelMovement(vector: CGPoint)
    case launchProjectile
}

extension GameData: Codable {
    enum CodingKeys: String, CodingKey {
        case gameBoard
        case tankMovement
        case barrelMovement
        case launchProjectile
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let gameBoard = try container.decodeIfPresent(URL.self, forKey: .gameBoard) {
            self = .gameBoard(value: gameBoard)
        } else if let tankMovement = try container.decodeIfPresent(CGPoint.self, forKey: .tankMovement) {
            self = .tankMovement(vector: tankMovement)
        } else if let barrelMovement = try container.decodeIfPresent(CGPoint.self, forKey: .barrelMovement) {
            self = .barrelMovement(vector: barrelMovement)
        } else {
            self = .launchProjectile
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .gameBoard(let value):
            try container.encode(value, forKey: .gameBoard)
        case .tankMovement(let vector):
            try container.encode(vector, forKey: .tankMovement)
        case .barrelMovement(let vector):
            try container.encode(vector, forKey: .barrelMovement)
        case .launchProjectile:
            try container.encode("", forKey: .launchProjectile)
        }
    }
}
