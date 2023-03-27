//
//  GraphNode.swift
//  Terrain4
//
//  Created by Richard Shields on 3/26/23.
//

import Foundation

class GraphNode: Codable {
    let id = UUID()
    
    init() {}
    
    required init(from decoder: Decoder) throws {}
    
    func encode(to encoder: Encoder) throws {}
}
