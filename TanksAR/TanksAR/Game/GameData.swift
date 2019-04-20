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
}

extension GameData: Codable {
    enum CodingKeys: String, CodingKey {
        case gameBoard
        case tankMovement
        case barrelMovement
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let gameBoard = try container.decodeIfPresent(URL.self, forKey: .gameBoard) {
            self = .gameBoard(value: gameBoard)
        } else if let tankMovement = try container.decodeIfPresent(CGPoint.self, forKey: .tankMovement) {
            self = .tankMovement(vector: tankMovement)
        } else {
            self = .barrelMovement(vector: try container.decode(CGPoint.self, forKey: .barrelMovement))
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
        }
    }
}
