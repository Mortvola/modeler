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
    func importObj(url: URL) throws {
        let meshBufferAllocator = MTKMeshBufferAllocator(device: MetalView.shared.device)

        let asset = MDLAsset(url: url, vertexDescriptor: MeshAllocator.vertexDescriptor(), bufferAllocator: meshBufferAllocator)
        
        let meshes = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]
        
        print("\(meshes.count)")
        
        for mdlMesh in meshes {
            mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, normalAttributeNamed: MDLVertexAttributeNormal, tangentAttributeNamed: MDLVertexAttributeTangent)

            let mesh = try MTKMesh(mesh: mdlMesh, device: MetalView.shared.device)

            let object = Mesh(mesh: mesh, model: self)

            object.material = Renderer.shared.materialManager.getMaterial(materialId: nil)

            self.objects.append(TreeNode(mesh: object))
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
}


class TemporaryObject: Decodable {
    var mesh: Mesh? = nil
    var point: Point? = nil
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            mesh = try container.decode(Mesh.self)
        }
        catch {
            do {
                point = try container.decode(Point.self)
            }
            catch {
                print("Unkonwn object")
            }
        }
    }
}
