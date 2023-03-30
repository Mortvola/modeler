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

                    object.material = Renderer.shared.materialManager.getMaterial(materialId: nil)

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
        for object in objects {
            switch object.content {
            case .mesh(let mesh):
                let center = mesh.getCenter()
                
                mesh.offset(-center)
            default:
                break
            }
        }
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
