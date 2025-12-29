//
//  ColoredSwitchToggleStyle.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 28.12.25.
//

import SwiftUI

struct ColoredSwitchToggleStyle: ToggleStyle {
    var onColor: Color = .green
    var offColor: Color = .gray

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label

            Spacer()

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(configuration.isOn ? onColor : offColor)
                .frame(width: 52, height: 32)
                .overlay(
                    Circle()
                        .fill(.white)
                        .padding(3)
                        .offset(x: configuration.isOn ? 10 : -10)
                        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isOn)
                )
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}
