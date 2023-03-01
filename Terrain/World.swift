//
//  Loader.swift
//  Terrain
//
//  Created by Richard Shields on 2/25/23.
//

import Foundation
import Metal

class World {
    let tilePadding = 3;
    
    class Tile {
        var offsetX: Float
        var offsetZ: Float
        var tile: TerrainTile?
        
        init(offsetX: Float, offsetZ: Float) {
            self.offsetX = offsetX
            self.offsetZ = offsetZ
        }
    }
    
    var tileGrid: [[Tile]] = [];
    
    var tileDict: [String: TerrainTile] = [:]
    
    // var scale = Float(1.0)
    
    var percentComplete = 0.0
    
    var terrainLoaded = false
    
    init() {
        initTileGrid()
    }
    
    func loadTiles(x: Int, z: Int, dimension: Int, renderer: Renderer) async throws {
        let totalTiles = pow(Double(tilePadding) * 2.0 + 1.0, 2)
        var tilesLoaded = 0;
        // let promises: Promise<void | void[]>[] = [];
        
        for z2 in stride(from: -tilePadding, to: tilePadding + 1, by: 1) {
            for x2 in stride(from: -tilePadding, to: tilePadding + 1, by: 1) {
                try await loadTile(gridX: x2 + tilePadding, gridZ: z2 + tilePadding, x: x + x2, z: z + z2, dimension: dimension, renderer: renderer)
                tilesLoaded += 1;
                print("tiles loaded: \(tilesLoaded)")
                percentComplete = Double(tilesLoaded) / totalTiles
                // this.onLoadChange(percentComplete);
                
                if (percentComplete >= 1) {
                    terrainLoaded = true;
                }
            }
        }
        
        setTileGridOffsets();
    }
    
    func loadTile(
        gridX: Int,
        gridZ: Int,
        x: Int,
        z: Int,
        dimension: Int,
        renderer: Renderer
    ) async throws {
        let dictionaryKey = "\(x)-\(z)-\(dimension)"
        
        if let tile = tileDict[dictionaryKey] {
            tileGrid[gridZ][gridX].tile = tile;
        }
        else {
            let tile = TerrainTile(x: x, y: z, dimension: dimension, device: renderer.device, view: renderer.view)
            // tile.setScale(scale: self.scale);
            tileDict[dictionaryKey] = tile;
            
            tileGrid[gridZ][gridX].tile = tile;
            
            try await tile.load();
        }
    }
    
    func setTileRowOffsets(z: Int, zOffset: Float) {
        for x in stride(from: 1, to: tilePadding + 1, by: 1) {
            var prevTile = tileGrid[z][tilePadding + x - 1];
            var currentTile = tileGrid[z][tilePadding + x];
            
            if (prevTile.tile != nil && currentTile.tile != nil) {
                currentTile.offsetX = prevTile.offsetX
                + (prevTile.tile!.xDimension + currentTile.tile!.xDimension) / 2;
                currentTile.offsetZ = zOffset;
                currentTile.tile?.setTranslation(x: currentTile.offsetX, y: 0.0, z: currentTile.offsetZ)
            }
            
            prevTile = tileGrid[z][tilePadding - x + 1];
            currentTile = tileGrid[z][tilePadding - x];
            
            if (prevTile.tile != nil && currentTile.tile != nil) {
                currentTile.offsetX = prevTile.offsetX
                - (prevTile.tile!.xDimension + currentTile.tile!.xDimension) / 2;
                currentTile.offsetZ = zOffset;
                currentTile.tile!.setTranslation(x: currentTile.offsetX, y: 0.0, z: currentTile.offsetZ)
            }
        }
    }
    
    func setTileGridOffsets() {
        setTileRowOffsets(z: tilePadding, zOffset: 0.0)
        
        for z in stride(from: 1, to: tilePadding + 1, by: 1) {
            var prevTile = tileGrid[tilePadding + z - 1][tilePadding];
            let currentTile1 = tileGrid[tilePadding + z][tilePadding];
            
            if (prevTile.tile != nil && currentTile1.tile != nil) {
                currentTile1.offsetX = 0;
                currentTile1.offsetZ = prevTile.offsetZ
                + (prevTile.tile!.yDimension + currentTile1.tile!.yDimension) / 2;
                currentTile1.tile?.setTranslation(x: currentTile1.offsetX, y: 0.0, z: currentTile1.offsetZ)
            }
            
            prevTile = tileGrid[tilePadding - z + 1][tilePadding];
            let currentTile2 = tileGrid[tilePadding - z][tilePadding];
            
            if (prevTile.tile != nil && currentTile2.tile != nil) {
                currentTile2.offsetX = 0;
                currentTile2.offsetZ = prevTile.offsetZ
                - (prevTile.tile!.yDimension + currentTile2.tile!.yDimension) / 2;
                currentTile2.tile!.setTranslation(x: currentTile2.offsetX, y: 0.0, z: currentTile2.offsetZ)
            }
            
            for _ in stride(from: 1, to: tilePadding + 1, by: 1) {
                setTileRowOffsets(z: tilePadding + z, zOffset: currentTile1.offsetZ);
                setTileRowOffsets(z: tilePadding - z, zOffset: currentTile2.offsetZ);
            }
        }
    }
    
    func initTileGrid() {
        let gridDimension = tilePadding * 2 + 1;
        
        for _ in stride(from: 0, to: gridDimension, by: 1) {
            var row: [Tile] = [];
            
            for _ in stride(from: 0, to: gridDimension, by: 1) {
                row.append(Tile(offsetX: 0.0, offsetZ: 0.0));
                // tileRenderOrder.push({ x, y });
            }
            
            tileGrid.append(row);
        }
        
        //  this.tileRenderOrder.sort((a, b) => (
        //    (Math.abs(a.x - tilePadding) + Math.abs(a.y - tilePadding))
        //    - (Math.abs(b.x - tilePadding) + Math.abs(b.y - tilePadding))
        //  ));
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder) {
        self.tileGrid.forEach { row in
            row.forEach { tile in
                if let terrainTile = tile.tile {
                    terrainTile.objects.forEach { object in
                        object.draw(renderEncoder: renderEncoder, modelMatrix: terrainTile.modelMatrix)
                    }
                }
            }
        }
    }
    
    func getElevation(x: Float, y: Float) -> Float {
        (self.tileGrid[self.tilePadding][self.tilePadding].tile?.getElevation(x: x, y: y) ?? 0) + 2
    }
}
