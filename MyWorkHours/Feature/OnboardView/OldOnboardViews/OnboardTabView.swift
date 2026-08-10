//
//  OnBoardView.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 10.06.24.
//

import SwiftUI

struct OnBoardTabView: View {
    @ObservedObject var viewModel: OnboardViewModel
    
    var body: some View {
        TabView(selection: $viewModel.tabBarSelection) {
            ForEach(viewModel.onboardItems.indices, id: \.self) { index in
                OnboardItemView(viewModel: viewModel, item: viewModel.onboardItems[index])
                    .tag(index)
            }
            OnboardSettingsView(viewModel: viewModel)
                .tag(viewModel.onboardItems.count)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.5), value: viewModel.tabBarSelection)
    }
}

#Preview {
    OnBoardTabView(viewModel: OnboardViewModel(userDefaultsStore: UserDefaultsStore(), userSettingsStore: UserSettingsStore(userDefaultsStore: UserDefaultsStore())))
}
