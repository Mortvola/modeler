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
    @State private var type = ObjectType.sphere
    @Binding var isOpen: Bool
    @Binding var selectedItem: TreeNode?
    @Binding var model: Model?
    @State var sphereOptions = SphereOptions()
    @State var planeOptions = PlaneOptions()
    @State var boxOptions = BoxOptions()
    @State var cylinderOptions = CylinderOptions()
    @State var coneOptions = ConeOptions()
    @State var pointOptions = PointOptions()
    @State var billboardOptions = BillboardOptions()
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Type", selection: $type) {
                    ForEach(ObjectType.allCases, id: \.rawValue) { value in
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
                    case .point:
                        PointOptionsView(options: $pointOptions)
                    case .billboard:
                        BillboardOptionsView(options: $billboardOptions)
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
                            switch type {
                            case .sphere:
                                if let object = try? await model?.addSphere(options: sphereOptions) {
                                    selectedItem = TreeNode(mesh: object)
                                }
                            case .light:
                                break
                            case .plane:
                                if let object = try? await model?.addPlane(options: planeOptions) {
                                    selectedItem = TreeNode(mesh: object)
                                }
                            case .box:
                                if let object = try? await model?.addBox(options: boxOptions) {
                                    selectedItem = TreeNode(mesh: object)
                                }
                            case .cylinder:
                                if let object = try? await model?.addCylinder(options: cylinderOptions) {
                                    selectedItem = TreeNode(mesh: object)
                                }
                            case .cone:
                                if let object = try? await model?.addCone(options: coneOptions) {
                                    selectedItem = TreeNode(mesh: object)
                                }
                            case .point:
                                if let object = try? await model?.addPoint(options: pointOptions) {
                                    selectedItem = TreeNode(point: object)
                                }
                            case .billboard:
                                if let object = try? await model?.addBillboard(options: billboardOptions) {
                                    selectedItem = TreeNode(mesh: object)
                                }
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
