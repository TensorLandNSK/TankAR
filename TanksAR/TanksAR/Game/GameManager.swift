//
//  GameManager.swift
//  TanksAR
//
//  Created by tensor_guest on 19/04/2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import Foundation

enum GameData {
    case gameBoard(value: Data)
}

extension GameData: Codable {
    enum CodingKeys: String, CodingKey {
        case gameBoard
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self = .gameBoard(value: try container.decode(Data.self, forKey: .gameBoard))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .gameBoard(let value):
            try container.encode(value, forKey: .gameBoard)
        }
    }
}
