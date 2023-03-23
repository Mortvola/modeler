//
//  ListItemBase.swift
//  Terrain4
//
//  Created by Richard Shields on 3/22/23.
//

import SwiftUI

struct ListItemBase: View {
    @Binding var text: String
    var isSelected: Bool
    @State var editing = false
    @FocusState var isFocused: Bool
    var action: () -> Void
    
    var body: some View {
        HStack {
            if editing && isSelected {
                ListItemField(text: $text)
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }
                    .background {
                        Color(.white)
                    }
                    .foregroundColor(.black)
            }
            else {
                HStack {
                    Text(text)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if !isSelected {
                        action()
                        editing = false
                    }
                    else {
                        editing = true
                    }
                }
            }
        }
        .onChange(of: isSelected) { newState in
            if !newState {
                editing = false
            }
        }
        .onChange(of: isFocused) { newState in
            if !newState {
                editing = false
            }
        }
        .padding([.leading, .trailing], 8)
        .selected(selected: isSelected)
    }
}

struct ListItemBase_Previews: PreviewProvider {
    static var previews: some View {
        ListItemBase(text: .constant("test"), isSelected: false) {
            print("it worked")
        }
    }
}
