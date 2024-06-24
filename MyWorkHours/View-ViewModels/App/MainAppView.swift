//
//  AppView.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 12.06.24.
//

import SwiftUI

struct MainAppView: View {
    @StateObject var viewModel = OnBoardItems()
    var body: some View {
        Group {
            if viewModel.finishOnboarding == false {
                OnBoardTabView(viewModel: viewModel)
                    .transition(.move(edge: .bottom))
            } else {
                WorkingDaysTabView()
            }
        }
        .animation(.easeIn(duration: 0.5), value: viewModel.finishOnboarding)
    }
}

#Preview {
    MainAppView()
}
