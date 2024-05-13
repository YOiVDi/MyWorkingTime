//
//  Test.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 05.01.24.
//

import SwiftUI
import UserNotifications


struct PauseTimerView: View {
    @StateObject var viewModel = PauseTimerViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                TimerView(viewModel: viewModel)
                Buttons(viewModel: viewModel)
            }
            .navigationTitle("Timer")
            .navigationBarTitleDisplayMode(.inline)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.backGround)
        }
    }
}

#Preview {
    PauseTimerView()
}
