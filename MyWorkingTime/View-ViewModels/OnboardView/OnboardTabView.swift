//
//  OnBoardView.swift
//  MyWorkingTime
//
//  Created by Yordan Dimitrov on 10.06.24.
//

import SwiftUI

struct OnBoardTabView: View {
    @ObservedObject var viewModel: OnBoardItems
    
    var body: some View {
        TabView(selection: $viewModel.tabBarSelection) {
            ForEach(viewModel.onboardItems.indices, id: \.self) { index in
                    OnboardItemView(viewModel: viewModel, item: viewModel.onboardItems[index])
                        .tag(index)
            }
            OnboardSettingsView(viewModel: viewModel)
                .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.5), value: viewModel.tabBarSelection)
        .background(.black)
    }
}

#Preview {
    OnBoardTabView(viewModel: OnBoardItems())
}
