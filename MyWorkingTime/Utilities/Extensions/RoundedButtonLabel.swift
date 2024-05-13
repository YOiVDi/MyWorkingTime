//
//  ButtonModifier.swift
//  WorkingHours
//
//  Created by Yordan Dimitrov on 28.01.24.
//

import SwiftUI

struct RoundedButtonLabel: ViewModifier {
    
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(color)
            .foregroundColor(.white)
            .font(.title).fontWeight(.semibold)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension View {
    func customBtnLabel(_ color: Color) -> some View {

        modifier(RoundedButtonLabel(color: color))
    }
}
