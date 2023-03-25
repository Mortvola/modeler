//
//  MaterialManager.swift
//  Terrain4
//
//  Created by Richard Shields on 3/24/23.
//

import Foundation
import MetalKit

class MaterialManager: ObservableObject {
    @Published var materials: [UUID:MaterialWrapper] = [:]
    private var defaultMaterial: MaterialWrapper
    
    init() {
        defaultMaterial = MaterialWrapper.pbrMaterial(PbrMaterial())
    }
    
    func addMaterial(pbrMaterial: PbrMaterial) {
        let entry = materials[pbrMaterial.id]
        
        if entry == nil {
            materials[pbrMaterial.id] = MaterialWrapper.pbrMaterial(pbrMaterial)
        }
        
        // Make sure it is added to the pipeline
        Renderer.shared.pipelineManager?.pbrPipeline.addMaterial(pbrMaterial: pbrMaterial)
    }
    
    func addMaterial(simpleMaterial: SimpleMaterial) {
        let entry = materials[simpleMaterial.id]
        
        if entry == nil {
            materials[simpleMaterial.id] = MaterialWrapper.simpleMaterial(simpleMaterial)
        }
        
        // Make sure it is added to the pipeline
        Renderer.shared.pipelineManager?.billboardPipeline.addMaterial(material: simpleMaterial)
    }
    
    func removeObjectFromMaterial(object: RenderObject, materialId: UUID?) {
        // Remove object from current material object list
        if let materialId = materialId {
            if let material = materials[materialId] {
                let index = material.material.objects.firstIndex {
                    $0.id == object.id
                }
                
                if let index = index {
                    material.material.objects.remove(at: index)
                }
            }
        }
        else {
            let index = defaultMaterial.material.objects.firstIndex {
                $0.id == object.id
            }
            
            if let index = index {
                defaultMaterial.material.objects.remove(at: index)
            }
        }
    }
    
    func addObjectToMaterial(object: RenderObject, materialId: UUID?) {
        if let materialId = materialId {
            var materialEntry = materials[materialId]
            
            if materialEntry == nil {
                materialEntry = defaultMaterial
            }
            
            if let materialEntry = materialEntry {
                setMaterial(object: object, materialEntry: materialEntry)
            }
        }
        else {
            setMaterial(object: object, materialEntry: defaultMaterial)
        }
    }
    
    func setMaterial(object: RenderObject, materialEntry: MaterialWrapper) {
        object.material = materialEntry

        switch materialEntry {
        case .pbrMaterial(let m):
            m.objects.append(object)
            Renderer.shared.pipelineManager?.pbrPipeline.addMaterial(pbrMaterial: m)
        case .billboardMaterial:
            break //m.objects.append(self)
        case .pointMaterial:
            break //m.objects.append(self)
        case .simpleMaterial:
            break
        }
    }
}
