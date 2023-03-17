//
//  Camera.swift
//  Terrain4
//
//  Created by Richard Shields on 3/16/23.
//

import Foundation

extension File {
    struct Camera: Codable {
        var position: Vec3
        var yaw: Float
        var pitch: Float
        
        init(position: Vec3, yaw: Float, pitch: Float) {
            self.position = position
            self.yaw = yaw
            self.pitch = pitch
        }
        
        enum CodingKeys: CodingKey {
            case position
            case yaw
            case pitch
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.position = try container.decode(Vec3.self, forKey: .position)
            self.yaw = try container.decode(Float.self, forKey: .yaw)
            self.pitch = try container.decode(Float.self, forKey: .pitch)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(position, forKey: .position)
            try container.encode(yaw, forKey: .yaw)
            try container.encode(pitch, forKey: .pitch)
        }
    }
}
