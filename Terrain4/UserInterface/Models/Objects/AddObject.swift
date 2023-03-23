//
//  AddObject.swift
//  Terrain
//
//  Created by Richard Shields on 3/7/23.
//

import SwiftUI

struct AddObject: View {
    var undoManager: UndoManager?
    @EnvironmentObject private var file: SceneDocument
    @State private var type = ObjectStore.ObjectType.sphere
    @Binding var isOpen: Bool
    @Binding var selectedItem: TreeNode?
    @Binding var model: Model?
    @State var sphereOptions = SphereOptions()
    @State var planeOptions = PlaneOptions()
    @State var boxOptions = BoxOptions()
    @State var cylinderOptions = CylinderOptions()
    @State var coneOptions = ConeOptions()
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Type", selection: $type) {
                    ForEach(ObjectStore.ObjectType.allCases, id: \.rawValue) { value in
                        Text(value.name).tag(value)
                    }
                }
                VStack {
                    switch type {
                    case .sphere:
                        SphereOptionsView(options: $sphereOptions)
                    case .light:
                        EmptyView()
                    case .plane:
                        PlaneOptionsView(options: $planeOptions)
                    case .box:
                        BoxOptionsView(options: $boxOptions)
                    case .cylinder:
                        CylinderOptionsView(options: $cylinderOptions)
                    case .cone:
                        ConeOptionsView(options: $coneOptions)
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Add Object")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isOpen = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        Task {
                            var object: RenderObject?
                            switch type {
                            case .sphere:
                                object = try? await model?.addSphere(options: sphereOptions)
                            case .light:
                                break
                            case .plane:
                                object = try? await model?.addPlane(options: planeOptions)
                            case .box:
                                object = try? await model?.addBox(options: boxOptions)
                            case .cylinder:
                                object = try? await model?.addCylinder(options: cylinderOptions)
                            case .cone:
                                object = try? await model?.addCone(options: coneOptions)
                            }
                            
                            if let object = object {
                                selectedItem = TreeNode(object: object)
                            }
                            
                            undoManager?.registerUndo(withTarget: file) { _ in
                                print("undo add object")
                            }
                            isOpen = false
                        }
                    }
                }
            }
        }
    }
}

//struct AddObject_Previews: PreviewProvider {
//    static var previews: some View {
//        AddObject(isOpen: .constant(true), selected)
//    }
//}
