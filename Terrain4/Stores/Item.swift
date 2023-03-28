//
//  Item.swift
//  Terrain4
//
//  Created by Richard Shields on 3/27/23.
//

import Foundation

class Item: ObservableObject, Equatable, Codable {
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs === rhs
    }
    
    @Published var name: String
    
    init(name: String) {
        self.name = name
    }
    
    enum CodingKeys: CodingKey {
        case name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
    }
}

