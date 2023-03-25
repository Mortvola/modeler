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
    
    @Published var lights: [Light] = []
    
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

        lights = try container.decode([Light].self, forKey: .lights)
        transforms = try container.decode([Transform].self, forKey: .transforms)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(objects, forKey: .objects)
        try container.encode(lights, forKey: .lights)
        try container.encode(transforms, forKey: .transforms)
        
        try super.encode(to: encoder)
    }
    
    func addLight() -> Light {
        let light = Light(model: self)
        light.intensity  = Vec3(50, 50, 50)
        
        self.lights.append(light)
        
        return light
    }
    
    @MainActor
    func addSphere(options: SphereOptions) async throws -> Mesh {
        guard let device = Renderer.shared.device else {
            throw Errors.deviceNotSet
        }
        
        let mesh = try SphereAllocator.allocate(device: device, diameter: options.diameter, radialSegments: options.radialSegments, verticalSegments: options.verticalSegments, hemisphere: options.hemisphere)
        
        let object = Mesh(mesh: mesh, model: self)
        
        object.setMaterial(materialId: nil)

        self.objects.append(TreeNode(mesh: object))

        return object
    }
    
    @MainActor
    func addPlane(options: PlaneOptions) async throws -> Mesh {
        guard let device = Renderer.shared.device else {
            throw Errors.deviceNotSet
        }
        
        let mesh = try RetangleAllocator.allocate(device: device, dimensions: options.dimensions, segments: options.segments)
        
        let object = Mesh(mesh: mesh, model: self)
        
        object.setMaterial(materialId: nil)

        self.objects.append(TreeNode(mesh: object))

        return object
    }
    
    @MainActor
    func addBox(options: BoxOptions) async throws -> Mesh {
        guard let device = Renderer.shared.device else {
            throw Errors.deviceNotSet
        }
        
        let mesh = try BoxAllocator.allocate(device: device, dimensions: options.dimensions, segments: options.segments)
        
        let object = Mesh(mesh: mesh, model: self)
        
        object.setMaterial(materialId: nil)

        self.objects.append(TreeNode(mesh: object))

        return object
    }
    
    @MainActor
    func addCylinder(options: CylinderOptions) async throws -> Mesh {
        guard let device = Renderer.shared.device else {
            throw Errors.deviceNotSet
        }
        
        let mesh = try CylinderAllocator.allocate(device: device, options: options)
        
        let object = Mesh(mesh: mesh, model: self)
        
        object.setMaterial(materialId: nil)

        self.objects.append(TreeNode(mesh: object))
        
        return object
    }

    @MainActor
    func addCone(options: ConeOptions) async throws -> Mesh {
        guard let device = Renderer.shared.device else {
            throw Errors.deviceNotSet
        }
        
        let mesh = try ConeAllocator.allocate(device: device, options: options)
        
        let object = Mesh(mesh: mesh, model: self)

        object.setMaterial(materialId: nil)

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
        
//        let material = try await Renderer.shared.pipelineManager?.pointPipeline.addMaterial(device: device, view: view, descriptor: nil)
//
//        material?.objects.append(object)
//
//        self.objects.append(TreeNode(point: object))
        
        return object
    }
    
    @MainActor
    func addBillboard(options: BillboardOptions) async throws -> Billboard {
        let object = Billboard(model: self)
        object.size = options.dimensions
        
        object.setMaterial(materialId: nil)

        self.objects.append(TreeNode(billboard: object))
        
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
