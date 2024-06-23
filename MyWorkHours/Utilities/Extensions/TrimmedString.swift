//
//  Trimming.swift
//  MyWorkingTime
//
//  Created by Yordan Dimitrov on 07.06.24.
//

import SwiftUI

struct TrimmedString: ViewModifier {
    
    @Binding var text: String
    
    func body(content: Content) -> some View {
        content
            .onChange(of: text) { oldValue, newValue in
                let trimmedValue = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedValue != newValue {
                    text = trimmedValue
                }
            }
    }
    
}

extension View {
    func trimmedString(_ text: Binding<String>) -> some View {
        self.modifier(TrimmedString(text: text))
    }
}
