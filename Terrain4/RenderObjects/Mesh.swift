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
    
    init(points: [Float], texcoords: [Float], normals: [Float], submeshes: [Submesh], model: Model) throws {
        self.mesh = try Mesh.makeMesh(points: points, texcoords: texcoords, normals: normals, submeshes: submeshes)

        super.init(model: model)
    }
    
    override func getInstanceData(frame: Int) -> (MTLBuffer?, Int) {
        let (u, offset) = self.getModelMatrixUniform(index: frame, instances: instanceData.count)
        
        withUnsafeMutableBytes(of: &u[0]) { rawPtr in
            let instData = rawPtr.baseAddress!.assumingMemoryBound(to: ModelMatrixUniforms.self)
            
            for i in 0..<instanceData.count {
                // Pass the normal matrix (derived from the model matrix) to the vertex shader
                let modelMatrix = instanceData[i].transformation
                
                var normalMatrix = matrix_float3x3(columns: (
                    vector_float3(modelMatrix[0][0], modelMatrix[0][1], modelMatrix[0][2]),
                    vector_float3(modelMatrix[1][0], modelMatrix[1][1], modelMatrix[1][2]),
                    vector_float3(modelMatrix[2][0], modelMatrix[2][1], modelMatrix[2][2])
                ));
                
                normalMatrix = normalMatrix.inverse.transpose;
                
                instData[i].normalMatrix = normalMatrix
                instData[i].modelMatrix = modelMatrix
            }
        }
        
        return (modelMatrixUniform, offset)
    }
    
    override func draw(renderEncoder: MTLRenderCommandEncoder) throws {
        if instanceData.count > 0 {
            // Pass the vertex and index information to the vertex shader
            for (i, buffer) in self.mesh.vertexBuffers.enumerated() {
                renderEncoder.setVertexBuffer(buffer.buffer, offset: buffer.offset, index: i)
            }
            
            for submesh in mesh.submeshes {
                renderEncoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset, instanceCount: instanceData.count)
            }
        }
    }

    enum CodingKeys: CodingKey {
        case type
        case points
        case texcoords
        case normals
        case submeshes
    }
    
    struct Submesh: Decodable {
        var primitiveType: UInt
        var indexes: [Int]
    }
    
    static func getPrimitiveType(type: MDLGeometryType) throws -> MTLPrimitiveType {
        switch type {
        case .points:
            return .point
        case .lines:
            return .line
        case .quads:
            throw Errors.unknownGeometryType
        case .triangleStrips:
            return .triangleStrip
        case .triangles:
            return .triangle
        default:
            throw Errors.unknownGeometryType
        }
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

        for i in 0..<numberOfPoints {
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

    static func makeCoordBuffer(points: [Float], allocator: MTKMeshBufferAllocator) -> (MDLMeshBuffer, Int) {
        let numberOfPoints = points.count / 6
        
        let unsafeMutablePointer = UnsafeMutablePointer<Float>.allocate(capacity: numberOfPoints * 6)

        for i in 0..<numberOfPoints {
            unsafeMutablePointer[i * 6 + 0] = points[i * 6 + 0]
            unsafeMutablePointer[i * 6 + 1] = points[i * 6 + 1]
            unsafeMutablePointer[i * 6 + 2] = points[i * 6 + 2]
            unsafeMutablePointer[i * 6 + 3] = points[i * 6 + 3]
            unsafeMutablePointer[i * 6 + 4] = points[i * 6 + 4]
            unsafeMutablePointer[i * 6 + 5] = points[i * 6 + 5]
        }

        let bufferPointer = UnsafeBufferPointer(start: unsafeMutablePointer, count: numberOfPoints * 6)
        let data = Data(buffer: bufferPointer)
        
        return (allocator.newBuffer(with: data, type: .vertex), numberOfPoints)
    }

    static func makeNormalBuffer(normals: [Float], allocator: MTKMeshBufferAllocator) -> MDLMeshBuffer {
        let numberOfPoints = normals.count / 3

        let unsafeMutablePointer = UnsafeMutablePointer<Float>.allocate(capacity: numberOfPoints * 8)
        
        for i in 0..<numberOfPoints {
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

            for i in 0..<submesh.indexes.count {
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
        
        let submeshes = try container.decode([Submesh].self, forKey: .submeshes)
        
        self.mesh = try Mesh.makeMesh(points: points, texcoords: texcoords, normals: normals, submeshes: submeshes)

        try super.init(from: decoder)
    }

    private static func makeMesh(points: [Float], texcoords: [Float], normals: [Float], submeshes: [Submesh]) throws -> MTKMesh {
        let allocator = MTKMeshBufferAllocator(device: MetalView.shared.device)

        var vertexBuffers: [MDLMeshBuffer] = []

        let (coordBuffer, numberOfPoints) = Mesh.makeCoordBuffer(points: points, texcoords: texcoords, allocator: allocator)
        vertexBuffers.append(coordBuffer)

        let normalBuffer = Mesh.makeNormalBuffer(normals: normals, allocator: allocator)
        vertexBuffers.append(normalBuffer)

        let mdlSubmeshes = try Mesh.makeSubmeshes(submeshes: submeshes, allocator: allocator)

        let mdlMesh = MDLMesh(vertexBuffers: vertexBuffers, vertexCount: numberOfPoints, descriptor: MeshAllocator.vertexDescriptor(), submeshes: mdlSubmeshes)

        mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, normalAttributeNamed: MDLVertexAttributeNormal, tangentAttributeNamed: MDLVertexAttributeTangent)

        return try MTKMesh(mesh: mdlMesh, device: MetalView.shared.device)
    }
    
    static func makeMesh(points: [Float], normals: [Float], submeshes: [Submesh]) throws -> MTKMesh {
        let allocator = MTKMeshBufferAllocator(device: MetalView.shared.device)

        var vertexBuffers: [MDLMeshBuffer] = []

        let (coordBuffer, numberOfPoints) = Mesh.makeCoordBuffer(points: points, allocator: allocator)
        vertexBuffers.append(coordBuffer)

        let normalBuffer = Mesh.makeNormalBuffer(normals: normals, allocator: allocator)
        vertexBuffers.append(normalBuffer)

        let mdlSubmeshes = try Mesh.makeSubmeshes(submeshes: submeshes, allocator: allocator)

        let mdlMesh = MDLMesh(vertexBuffers: vertexBuffers, vertexCount: numberOfPoints, descriptor: MeshAllocator.vertexDescriptor(), submeshes: mdlSubmeshes)

        mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, normalAttributeNamed: MDLVertexAttributeNormal, tangentAttributeNamed: MDLVertexAttributeTangent)

        return try MTKMesh(mesh: mdlMesh, device: MetalView.shared.device)
    }
    
    override func encode(to encoder: Encoder) throws {
        do {
            try super.encode(to: encoder)
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            let (vertices, texcoords) = mesh.getCoordsFromBuffer()
            let (normals, _) = mesh.getNormalsFrombuffer()
            
            try container.encode(vertices, forKey: .points)
            try container.encode(texcoords, forKey: .texcoords)
            try container.encode(normals, forKey: .normals)
            
            try container.encode(mesh.submeshes, forKey: .submeshes)
            
            try super.encode(to: encoder)
        }
        catch {
            print(error)
            throw error
        }
    }

    func getCenter() -> Vec3 {
        var center = Vec3(0, 0, 0)
        
        let buffer = mesh.vertexBuffers[0]
        let points = buffer.buffer.contents().bindMemory(to: Float.self, capacity: buffer.length)
        
        let bytesPerPoint = MemoryLayout<Vec3>.size + MemoryLayout<Vec2>.size
        let floatsPerPoint = bytesPerPoint / MemoryLayout<Float>.size
        
        let count = buffer.length / MemoryLayout<Float>.size
        
        for i in stride(from: 0, to: count, by: floatsPerPoint) {
            center += Vec3(
                points[i + 0],
                points[i + 1],
                points[i + 2]
            )
        }
        
        center /= (Float(count) / Float(floatsPerPoint))
        
        return center
    }

    func getExtents() -> (Vec3, Vec3) {
        let buffer = mesh.vertexBuffers[0]
        let points = buffer.buffer.contents().bindMemory(to: Float.self, capacity: buffer.length)
        
        let bytesPerPoint = MemoryLayout<Vec3>.size + MemoryLayout<Vec2>.size
        let floatsPerPoint = bytesPerPoint / MemoryLayout<Float>.size
        
        let count = buffer.length / MemoryLayout<Float>.size
        
        var minimum = Vec3(Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude, Float.greatestFiniteMagnitude)
        var maximum = Vec3(-Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude, -Float.greatestFiniteMagnitude)

        for i in stride(from: 0, to: count, by: floatsPerPoint) {
            minimum.x = min(minimum.x, points[i + 0])
            minimum.y = min(minimum.y, points[i + 1])
            minimum.z = min(minimum.z, points[i + 2])

            maximum.x = max(maximum.x, points[i + 0])
            maximum.y = max(maximum.y, points[i + 1])
            maximum.z = max(maximum.z, points[i + 2])
        }
        
        return (minimum, maximum)
    }
    
    func offset(_ offset: Vec3) {
        let buffer = mesh.vertexBuffers[0]
        let points = buffer.buffer.contents().bindMemory(to: Float.self, capacity: buffer.length)
        
        let bytesPerPoint = MemoryLayout<Vec3>.size + MemoryLayout<Vec2>.size
        let floatsPerPoint = bytesPerPoint / MemoryLayout<Float>.size
        
        let count = buffer.length / MemoryLayout<Float>.size
        
        for i in stride(from: 0, to: count, by: floatsPerPoint) {
            points[i + 0] += offset.x
            points[i + 1] += offset.y
            points[i + 2] += offset.z
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

        try container.encode(self.primitiveType.rawValue, forKey: .primitiveType)
    
        let indexes: [Int] = readIndexes()
        
        try container.encode(indexes, forKey: .indexes)
    }
    
    func readIndexes() -> [Int] {
        if self.indexType == .uint32 {
            let indexes: [Int32] = readIndexes()
            
            return indexes.map {
                Int($0)
            }
        }
        
        
        let indexes: [Int16] = readIndexes()
        
        return indexes.map {
            Int($0)
        }
    }
    
    func readIndexes<T>() -> [T] {
        let buffer = self.indexBuffer
        let points = buffer.buffer.contents().bindMemory(to: T.self, capacity: buffer.length)
        
        var indexes: [T] = []
        
        let count = buffer.length / MemoryLayout<T>.size
        for i in 0..<count {
            indexes.append(points[i])
        }
        
        return indexes
    }
}

extension MTKMesh {
    func getCoordsFromBuffer() -> ([Float], [Float]) {
        let buffer = self.vertexBuffers[0]
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

    func getNormalsFrombuffer() -> ([Float], [Float]) {
        let buffer = self.vertexBuffers[1]
        let values = buffer.buffer.contents().bindMemory(to: Float.self, capacity: buffer.length)

        var normals: [Float] = []
        var tangents: [Float] = []
        
        let bytesPerPoint = MemoryLayout<Vec3>.size * 2
        let floatsPerPoint = bytesPerPoint / MemoryLayout<Float>.size
        
        let count = buffer.length / MemoryLayout<Float>.size
        
        for i in stride(from: 0, to: count, by: floatsPerPoint) {
            normals.append(values[i + 0])
            normals.append(values[i + 1])
            normals.append(values[i + 2])
            
            tangents.append(values[i + 4])
            tangents.append(values[i + 5])
            tangents.append(values[i + 6])
        }
        
        return (normals, tangents)
    }
}
