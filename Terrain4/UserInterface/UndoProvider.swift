//
//  Provider.swift
//  Terrain4
//
//  Created by Richard Shields on 3/19/23.
//

import SwiftUI

struct UndoProvider<WrappedView, Value>: View where WrappedView: View {
    @Environment(\.undoManager) var undoManager
    @StateObject var handler: UndoHandler<Value> = UndoHandler()
    
    var wrappedView: (Binding<Value>) -> WrappedView
    var binding: Binding<Value>
    
    init(
        _ binding: Binding<Value>,
        @ViewBuilder wrappedView: @escaping (Binding<Value>) -> WrappedView
    ) {
        self.binding = binding
        self.wrappedView = wrappedView
    }
    
    var interceptedBinding: Binding<Value> {
        Binding {
            self.binding.wrappedValue
        } set: { newValue in
            self.handler.registerUndo(from: self.binding.wrappedValue, to: newValue)
            self.binding.wrappedValue = newValue
        }
    }
    
    var body: some View {
        wrappedView(self.interceptedBinding).onAppear {
            self.handler.binding = self.binding
            self.handler.undoManager = self.undoManager
        }
        .onChange(of: self.undoManager) { undoManager in
            self.handler.undoManager = undoManager
        }
    }
}

struct UndoProvider_Previews: PreviewProvider {
    static var test: String = ""
    
    static var previews: some View {
        UndoProvider(.constant(test)) { $value in
            TextField("Test", text: $value)
        }
    }
}

class UndoHandler<Value>: ObservableObject {
    var binding: Binding<Value>?
    weak var undoManager: UndoManager?
    
    func registerUndo(from oldValue: Value, to newValue: Value) {
        undoManager?.registerUndo(withTarget: self) { handler in
            handler.registerUndo(from: newValue, to: oldValue)
            handler.binding?.wrappedValue = oldValue
        }
    }
}
