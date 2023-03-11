//
//  NumericField.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/20/22.
//

import SwiftUI
import Combine

public extension String {
    func numericValue() -> String {
        var hasFoundDecimal = false
        var index = 0
        return self.filter {
            if $0.isWholeNumber {
                defer { index += 1}
                return true
            }

            if $0 == "-" {
                defer { index += 1}
                return index == 0
            }
            
            if String($0) == (Locale.current.decimalSeparator ?? ".") {
                defer { hasFoundDecimal = true; index += 1 }
                return !hasFoundDecimal
            }
            
            return false
        }
    }
}

struct NumericField: View {
    @State private var valueString: String = ""
    @Binding private var value: Float
    private let formatter: NumberFormatter = NumberFormatter()
    @FocusState private var isFocused: Bool

    init(value: Binding<Float>) {
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 5
        
        _value = value
        let value = value.wrappedValue;
        let string = formatter.string(from: NSNumber(value: value)) ?? "0"
        _valueString = State(initialValue: string)
    }

    private func numberChanged(newValue: String) {
        let numeric = newValue.numericValue()
        if newValue != numeric {
            valueString = numeric
        }
        value = formatter.number(from: valueString)?.floatValue ?? 0
    }

    var body: some View {
        TextField("Amount", text: $valueString)
            .onChange(of: valueString, perform: numberChanged(newValue:))
            .focused($isFocused)
            .onChange(of: isFocused) { isFocused in
                if (!isFocused) {
                    let string = formatter.string(from: NSNumber(value: value))
                    valueString = string ?? ""
                }
            }
            .multilineTextAlignment(.trailing)
            .keyboardType(.numbersAndPunctuation)
            .monospacedDigit()
    }
}

struct NumericField_Previews: PreviewProvider {
    static let value: Float = 100.0

    static var previews: some View {
        NumericField(value: .constant(value))
    }
}
