//
//  Mesh.swift
//  Terrain
//
//  Created by Richard Shields on 3/6/23.
//

import Foundation
import Metal
import MetalKit

class Mesh: RenderObject {
    let mesh: MTKMesh
    
    init(mesh: MTKMesh, model: Model) {
        self.mesh = mesh

        super.init(model: model)
    }
    
    override func draw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, pbrProperties: PbrProperties?, frame: Int) throws {
        // Pass the normal matrix (derived from the model matrix) to the vertex shader
        var normalMatrix = matrix_float3x3(columns: (
            vector_float3(modelMatrix[0][0], modelMatrix[0][1], modelMatrix[0][2]),
            vector_float3(modelMatrix[1][0], modelMatrix[1][1], modelMatrix[1][2]),
           vector_float3(modelMatrix[2][0], modelMatrix[2][1], modelMatrix[2][2])
        ));
        
        normalMatrix = normalMatrix.inverse.transpose;

        let u = getUniformsBuffer(index: frame)
        u[0].normalMatrix = normalMatrix

        // Pass the light information
        u[0].numberOfLights = Int32(self.lights.count)
        
        withUnsafeMutableBytes(of: &u[0].lights) { rawPtr in
            let light = rawPtr.baseAddress!.assumingMemoryBound(to: Lights.self)

            for i in stride(from: 0, to: self.lights.count, by: 1) {
                light[i].position = self.lights[i].position
                light[i].intensity = self.lights[i].intensity
            }
        }

        u[0].albedo = pbrProperties?.albedo ?? Vec3(1.0, 1.0, 1.0)
        u[0].normals = pbrProperties?.normal ?? Vec3(0.5, 0.5, 1.0)
        u[0].metallic = pbrProperties?.metallic ?? 1.0
        u[0].roughness = pbrProperties?.roughness ?? 1.0

        //        withUnsafeMutableBytes(of: &lightData.intensity) { rawPtr in
//            let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: vector_float3.self)
//
//            for i in stride(from: 0, to: self.lights.count, by: 1) {
//                ptr[i] = self.lights[i].intensity
//            }
//        }
        
        try self.simpleDraw(renderEncoder: renderEncoder, modelMatrix: modelMatrix, frame: frame)
    }
    
    override func simpleDraw(renderEncoder: MTLRenderCommandEncoder, modelMatrix: Matrix4x4, frame: Int) throws {
        
        let u = getUniformsBuffer(index: frame)
        u[0].modelMatrix = modelMatrix

        renderEncoder.setVertexBuffer(self.uniforms, offset: 0, index: BufferIndex.nodeUniforms.rawValue)
        renderEncoder.setFragmentBuffer(self.uniforms, offset: 0, index: BufferIndex.nodeUniforms.rawValue)

        // Pass the vertex and index information to the vertex shader
        for (i, buffer) in self.mesh.vertexBuffers.enumerated() {
            renderEncoder.setVertexBuffer(buffer.buffer, offset: buffer.offset, index: i)
        }
        
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
        }
    }

    enum CodingKeys: CodingKey {
        case points
        case texcoords
        case normals
        case submeshes
    }
    
    struct Submesh: Decodable {
        var primitiveType: UInt
        var indexes: [Int]
    }
    
    static func getGeometryType(type: UInt) throws -> MDLGeometryType {
        switch (type) {
        case MTLPrimitiveType.point.rawValue:
            return .points

        case MTLPrimitiveType.line.rawValue:
            return .lines

        case MTLPrimitiveType.lineStrip.rawValue:
            throw Errors.unknownGeometryType

        case MTLPrimitiveType.triangle.rawValue:
            return .triangles

        case MTLPrimitiveType.triangleStrip.rawValue:
            return .triangleStrips

        default:
            break
        }
        
        throw Errors.unknownGeometryType
    }
    
    static func makeCoordBuffer(points: [Float], texcoords: [Float], allocator: MTKMeshBufferAllocator) -> (MDLMeshBuffer, Int) {
        let numberOfPoints = points.count / 3
        
        let unsafeMutablePointer = UnsafeMutablePointer<Float>.allocate(capacity: numberOfPoints * 6)

        for i in stride(from: 0, to: numberOfPoints, by: 1) {
            unsafeMutablePointer[i * 6 + 0] = points[i * 3 + 0]
            unsafeMutablePointer[i * 6 + 1] = points[i * 3 + 1]
            unsafeMutablePointer[i * 6 + 2] = points[i * 3 + 2]
            
            unsafeMutablePointer[i * 6 + 4] = texcoords[i * 2 + 0]
            unsafeMutablePointer[i * 6 + 5] = texcoords[i * 2 + 1]
        }
        
        let bufferPointer = UnsafeBufferPointer(start: unsafeMutablePointer, count: numberOfPoints * 6)
        let data = Data(buffer: bufferPointer)
        
        return (allocator.newBuffer(with: data, type: .vertex), numberOfPoints)
    }

    static func makeNormalBuffer(normals: [Float], allocator: MTKMeshBufferAllocator) -> MDLMeshBuffer {
        let numberOfPoints = normals.count / 3

        let unsafeMutablePointer = UnsafeMutablePointer<Float>.allocate(capacity: numberOfPoints * 8)
        
        for i in stride(from: 0, to: numberOfPoints, by: 1) {
            unsafeMutablePointer[i * 8 + 0] = normals[i * 3 + 0]
            unsafeMutablePointer[i * 8 + 1] = normals[i * 3 + 1]
            unsafeMutablePointer[i * 8 + 2] = normals[i * 3 + 2]
        }
        
        let bufferPointer = UnsafeBufferPointer(start: unsafeMutablePointer, count: numberOfPoints * 8)
        let data = Data(buffer: bufferPointer)
        
        return allocator.newBuffer(with: data, type: .vertex)
    }

    static func makeSubmeshes(submeshes: [Submesh], allocator: MTKMeshBufferAllocator) throws -> [MDLSubmesh] {
        let mdlSubmeshes = try submeshes.map { submesh in
            let unsafeMutablePointer = UnsafeMutablePointer<UInt16>.allocate(capacity: submesh.indexes.count)

            for i in stride(from: 0, to: submesh.indexes.count, by: 1) {
                unsafeMutablePointer[i] = UInt16(submesh.indexes[i])
            }
            
            let bufferPointer = UnsafeBufferPointer(start: unsafeMutablePointer, count: submesh.indexes.count)
            let data = Data(buffer: bufferPointer)
            
            let indexBuffer = allocator.newBuffer(with: data, type: .index)

            let geometryType = try Mesh.getGeometryType(type: submesh.primitiveType)
            
            return MDLSubmesh(indexBuffer: indexBuffer, indexCount: submesh.indexes.count, indexType: .uint16, geometryType: geometryType, material: nil)
        }

        return mdlSubmeshes
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let points = try container.decode([Float].self, forKey: .points)
        let texcoords = try container.decode([Float].self, forKey: .texcoords)
        let normals = try container.decode([Float].self, forKey: .normals)
        
        let allocator = MTKMeshBufferAllocator(device: Renderer.shared.device!)

        var vertexBuffers: [MDLMeshBuffer] = []

        let (coordBuffer, numberOfPoints) = Mesh.makeCoordBuffer(points: points, texcoords: texcoords, allocator: allocator)
        vertexBuffers.append(coordBuffer)
        
        let normalBuffer = Mesh.makeNormalBuffer(normals: normals, allocator: allocator)
        vertexBuffers.append(normalBuffer)
        
        let submeshes = try container.decode([Submesh].self, forKey: .submeshes)
        
        let mdlSubmeshes = try Mesh.makeSubmeshes(submeshes: submeshes, allocator: allocator)
        
        let mdlMesh = MDLMesh(vertexBuffers: vertexBuffers, vertexCount: numberOfPoints, descriptor: SphereAllocator.vertexDescriptor(), submeshes: mdlSubmeshes)

        mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, normalAttributeNamed: MDLVertexAttributeNormal, tangentAttributeNamed: MDLVertexAttributeTangent)

        self.mesh = try MTKMesh(mesh: mdlMesh, device: Renderer.shared.device!)

        try super.init(from: decoder)
    }

    private func getCoordsFromBuffer() -> ([Float], [Float]) {
        let buffer = mesh.vertexBuffers[0]
        let points = buffer.buffer.contents().bindMemory(to: Float.self, capacity: buffer.length)

        var vertices: [Float] = []
        var texcoords: [Float] = []
        
        let bytesPerPoint = MemoryLayout<Vec3>.size + MemoryLayout<Vec2>.size
        let floatsPerPoint = bytesPerPoint / MemoryLayout<Float>.size
        
        let count = buffer.length / MemoryLayout<Float>.size
        
        for i in stride(from: 0, to: count, by: floatsPerPoint) {
            vertices.append(points[i + 0])
            vertices.append(points[i + 1])
            vertices.append(points[i + 2])
            
            texcoords.append(points[i + 4])
            texcoords.append(points[i + 5])
        }
        
        return (vertices, texcoords)
    }
    
    private func getNormalsFrombuffer() -> [Float] {
        let buffer = mesh.vertexBuffers[1]
        let values = buffer.buffer.contents().bindMemory(to: Float.self, capacity: buffer.length)

        var normals: [Float] = []
        
        let bytesPerPoint = MemoryLayout<Vec3>.size * 2
        let floatsPerPoint = bytesPerPoint / MemoryLayout<Float>.size
        
        let count = buffer.length / MemoryLayout<Float>.size
        
        for i in stride(from: 0, to: count, by: floatsPerPoint) {
            normals.append(values[i + 0])
            normals.append(values[i + 1])
            normals.append(values[i + 2])
        }
        
        return normals
    }
    
    override func encode(to encoder: Encoder) throws {
        do {
            try super.encode(to: encoder)
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            let (vertices, texcoords) = getCoordsFromBuffer()
            let normals = self.getNormalsFrombuffer()
            
            try container.encode(vertices, forKey: .points)
            try container.encode(texcoords, forKey: .texcoords)
            try container.encode(normals, forKey: .normals)
            
            try container.encode(mesh.submeshes, forKey: .submeshes)
        }
        catch {
            print(error)
            throw error
        }
    }
}

extension MTKSubmesh: Encodable {
    enum CodingKeys: CodingKey {
        case indexCount
        case primitiveType
        case indexes
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

//        try container.encode(self.indexCount, forKey: .indexCount)
        try container.encode(self.primitiveType.rawValue, forKey: .primitiveType)
    
        if self.indexType == .uint32 {
            let indexes: [Int32] = readIndexes()
            
            try container.encode(indexes, forKey: .indexes)
        }
        else {
            let indexes: [Int16] = readIndexes()
            
            try container.encode(indexes, forKey: .indexes)
        }
    }
    
    func readIndexes<T>() -> [T] {
        let buffer = self.indexBuffer
        let points = buffer.buffer.contents().bindMemory(to: T.self, capacity: buffer.length)
        
        var indexes: [T] = []
        
        let count = buffer.length / MemoryLayout<T>.size
        for i in stride(from: 0, to: count, by: 1) {
            indexes.append(points[i])
        }
        
        return indexes
    }
}
