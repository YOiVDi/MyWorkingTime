//
//  Test.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 05.01.24.
//

import SwiftUI
import UserNotifications


struct PauseTimerView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @StateObject var viewModel = PauseTimerViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                TimerView(viewModel: viewModel)
                Buttons(viewModel: viewModel)
            }
            .navigationTitle(verticalSizeClass == .compact ? "" : "Timer")
            .navigationBarTitleDisplayMode(.inline)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    PauseTimerView()
}
