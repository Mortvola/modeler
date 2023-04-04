//
//  Model.swift
//  Terrain
//
//  Created by Richard Shields on 3/1/23.
//

import Foundation
import MetalKit

class Model: Node, Identifiable, Hashable {
    static func == (lhs: Model, rhs: Model) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    
    private static var modelCounter = 0
    
    @Published var objects: [TreeNode] = []
    
    @Published var transforms: [Transform] = []
    
    var modelMatrix = Matrix4x4.identity()
    var translate = Vec3(0.0, 0.0, 0.0)
    var rotation: Float = 0.0
    
    init() {
        super.init(name: "Model_\(Model.modelCounter)")
        Model.modelCounter += 1
    }
    
    enum CodingKeys: CodingKey {
        case id
        case objects
        case lights
        case transforms
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        try super.init(from: decoder)
        
        id = try container.decode(UUID.self, forKey: .id)
        objects = try container.decode([TreeNode].self, forKey: .objects)

        let lights = try container.decodeIfPresent([Light].self, forKey: .lights) ?? []
        
        for light in lights {
            objects.append(TreeNode(light: light))
        }

        transforms = try container.decode([Transform].self, forKey: .transforms)
        
        // Assign all of the child objects to this model
        for object in objects {
            switch object.content {
            case .mesh(let o):
                o.model = self
            case .point(let p):
                p.model = self
            default:
                break;
            }
        }

        // Assign all of the child lights to this model
        lights.forEach { light in
            light.model = self
        }
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(objects, forKey: .objects)
        try container.encode(transforms, forKey: .transforms)
        
        try super.encode(to: encoder)
    }
    
    func addLight() -> Light {
        let light = Light(model: self)
        light.intensity  = Vec3(50, 50, 50)
        
        self.objects.append(TreeNode(light: light))
        
        return light
    }
    
    @MainActor
    func importObj(url: URL) async throws {
        let meshBufferAllocator = MTKMeshBufferAllocator(device: MetalView.shared.device)

        let asset = MDLAsset(url: url, vertexDescriptor: MeshAllocator.vertexDescriptor(), bufferAllocator: meshBufferAllocator)
        
        let meshes = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]
        
        for mdlMesh in meshes {
            
            mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, normalAttributeNamed: MDLVertexAttributeNormal, tangentAttributeNamed: MDLVertexAttributeTangent)

            let meshCoords = mdlMesh.vertexBuffers[0].map().bytes.bindMemory(to: Float.self, capacity: mdlMesh.vertexCount * 6)
            let meshNormals = mdlMesh.vertexBuffers[1].map().bytes.bindMemory(to: Float.self, capacity: mdlMesh.vertexCount * 8)

            if let submeshes = mdlMesh.submeshes {
                for sm in submeshes {
                    let submesh: MDLSubmesh = sm as! MDLSubmesh

                    guard submesh.indexType == .uInt32 else {
                        throw Errors.invalidIndexType
                    }
                    
                    var objectMaterial: UUID? = nil
                    
                    if let material = submesh.material {
                        let path = url.deletingLastPathComponent().absoluteString
                        print(path)
                        objectMaterial = try await importMaterial(material: material, in: path)
                    }
                    
                    let indexes = submesh.indexBuffer.map().bytes.bindMemory(to: Int32.self, capacity: mdlMesh.vertexCount)
                    var points: [Float] = []
                    var normals: [Float] = []
                    var remappedIndexes: [Int] = []

                    var indexMap: [Int:Int] = [:]

                    for i in 0..<submesh.indexCount {
                        let index = Int(indexes[i])

                        if let mappedIndex = indexMap[index] {
                            remappedIndexes.append(mappedIndex)
                        }
                        else {
                            let newPointIndex = points.count / 6
                            indexMap[index] = newPointIndex
                            remappedIndexes.append(newPointIndex)

                            points.append(meshCoords[index * 6 + 0])
                            points.append(meshCoords[index * 6 + 1])
                            points.append(meshCoords[index * 6 + 2])
                            points.append(0)

                            points.append(meshCoords[index * 6 + 4])
                            points.append(meshCoords[index * 6 + 5])

                            normals.append(meshNormals[index * 8 + 0])
                            normals.append(meshNormals[index * 8 + 1])
                            normals.append(meshNormals[index * 8 + 2])
                            normals.append(0)
                        }
                    }

                    let newSubmesh = Mesh.Submesh(primitiveType: try Mesh.getPrimitiveType(type: submesh.geometryType).rawValue, indexes: remappedIndexes)

                    let newMesh = try Mesh.makeMesh(points: points, normals: normals, submeshes: [newSubmesh])

                    let object = Mesh(mesh: newMesh, model: self)
                    object.name = submesh.name

                    let material = Renderer.shared.materialManager.getMaterial(materialId: objectMaterial)

                    object.setMaterial(material: material)
                    
                    self.objects.append(TreeNode(mesh: object))
                }
            }
        }
    }

    @MainActor
    func addSphere(options: SphereOptions) async throws -> Mesh {
        let mesh = try SphereAllocator.allocate(diameter: options.diameter, radialSegments: options.radialSegments, verticalSegments: options.verticalSegments, hemisphere: options.hemisphere)
        
        let object = Mesh(mesh: mesh, model: self)
        
        object.setMaterial(material: nil)

        self.objects.append(TreeNode(mesh: object))

        return object
    }
    
    @MainActor
    func addPlane(options: PlaneOptions) async throws -> Mesh {
        let mesh = try RetangleAllocator.allocate(dimensions: options.dimensions, segments: options.segments)
        
        let object = Mesh(mesh: mesh, model: self)
        
        object.setMaterial(material: nil)

        self.objects.append(TreeNode(mesh: object))

        return object
    }
    
    @MainActor
    func addBox(options: BoxOptions) async throws -> Mesh {
        let mesh = try BoxAllocator.allocate(dimensions: options.dimensions, segments: options.segments)
        
        let object = Mesh(mesh: mesh, model: self)
        
        object.setMaterial(material: nil)

        self.objects.append(TreeNode(mesh: object))

        return object
    }
    
    @MainActor
    func addCylinder(options: CylinderOptions) async throws -> Mesh {
        let mesh = try CylinderAllocator.allocate(options: options)
        
        let object = Mesh(mesh: mesh, model: self)
        
        object.setMaterial(material: nil)

        self.objects.append(TreeNode(mesh: object))
        
        return object
    }

    @MainActor
    func addCone(options: ConeOptions) async throws -> Mesh {
        let mesh = try ConeAllocator.allocate(options: options)
        
        let object = Mesh(mesh: mesh, model: self)

        object.setMaterial(material: nil)

        self.objects.append(TreeNode(mesh: object))
        
        return object
    }

    @MainActor
    func addPoint(options: PointOptions) async throws -> Point {
//        guard let device = Renderer.shared.device else {
//            throw Errors.deviceNotSet
//        }
//
//        guard let view = Renderer.shared.view else {
//            throw Errors.viewNotSet
//        }

        let object = Point(model: self)
        object.size = options.size
        
//        let material = try await Renderer.shared.pipelineManager.pointPipeline.addMaterial(device: device, view: view, descriptor: nil)
//
//        material?.objects.append(object)
//
//        self.objects.append(TreeNode(point: object))
        
        return object
    }
    
    @MainActor
    func addBillboard(options: BillboardOptions) async throws -> Mesh {
        let object = try BillboardAllocator.allocate(model: self)
//        object.size = options.dimensions
        
        object.setMaterial(material: nil)

        self.objects.append(TreeNode(mesh: object))

        return object
    }
    
    func center() {
        var center = Vec3(0, 0, 0)
        var totalCount = 0
        
        let bytesPerPoint = MemoryLayout<Vec3>.size + MemoryLayout<Vec2>.size
        let floatsPerPoint = bytesPerPoint / MemoryLayout<Float>.size
        
        for object in objects {
            switch object.content {
            case .mesh(let mesh):
                let buffer = mesh.mesh.vertexBuffers[0]
                let points = buffer.buffer.contents().bindMemory(to: Float.self, capacity: buffer.length)
                
                let count = buffer.length / MemoryLayout<Float>.size
                
                for i in stride(from: 0, to: count, by: floatsPerPoint) {
                    center += Vec3(
                        points[i + 0],
                        points[i + 1],
                        points[i + 2]
                    )
                }
                
                totalCount += count / floatsPerPoint

            default:
                break
            }
        }
                
        center /= Float(totalCount)

        print(center)
        
        for object in objects {
            switch object.content {
            case .mesh(let mesh):
                mesh.offset(-center)
            default:
                break
            }
        }
    }
    
    func loadTexture(property: MDLMaterialProperty, layer: MaterialLayer, from path: String) async throws {
        do {
            switch property.type {
            case .URL:
                if let url = property.urlValue {
                    layer.texture = try await TextureManager.shared.addTexture(path: url.absoluteString)
                    layer.map = url.absoluteString
                }
            case .string:
                if let filename = property.stringValue {
                    layer.texture = try await TextureManager.shared.addTexture(path: "\(path)/\(filename)")
                    layer.map = filename
                }
            default:
                break
            }
        }
        catch {
            print(error)
            throw error
        }
    }
    
    func importMaterial(material: MDLMaterial, in path: String) async throws -> UUID {
        let pbrMaterial = PbrMaterial()
        pbrMaterial.name = material.name
        
        if let baseColor = material.property(with: .baseColor) {
            if baseColor.type == .color {
                if let color = baseColor.color {
                    if let c = color.components {
                        let v4 = Vec4(Float(c[0]), Float(c[1]), Float(c[2]), Float(c[3]))
                        pbrMaterial.albedo.color = v4
                        pbrMaterial.albedo.useSimple = true
                    }
                }
            }
            else {
                try await loadTexture(property: baseColor, layer: pbrMaterial.albedo, from: path)
            }
        }
        
        if let normals = material.property(with: .tangentSpaceNormal) {
            if normals.type == .float3 {
                pbrMaterial.normals.normal = normals.float3Value.vec4()
                pbrMaterial.normals.useSimple = true
            }
            else if normals.type == .float4 {
                pbrMaterial.normals.normal = normals.float4Value
                pbrMaterial.normals.useSimple = true
            }
            else {
                try await loadTexture(property: normals, layer: pbrMaterial.normals, from: path)
            }
        }
        
        if let metallic = material.property(with: .metallic) {
            if metallic.type == .float {
                pbrMaterial.metallic.value = metallic.floatValue
                pbrMaterial.metallic.useSimple = true
            }
            else {
                try await loadTexture(property: metallic, layer: pbrMaterial.metallic, from: path)
            }
        }
        
        if let roughness = material.property(with: .roughness) {
            if roughness.type == .float {
                pbrMaterial.roughness.value = roughness.floatValue
                pbrMaterial.roughness.useSimple = true
            }
            else {
                try await loadTexture(property: roughness, layer: pbrMaterial.roughness, from: path)
            }
        }
        
        Renderer.shared.materialManager.addMaterial(pbrMaterial)
        
        return pbrMaterial.id
    }
}
