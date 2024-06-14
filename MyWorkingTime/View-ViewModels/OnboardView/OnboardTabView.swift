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
        TabView {
            ForEach(viewModel.onboardItems, id: \.self) { item in
                OnboardItemView(viewModel: viewModel, item: item)
            }
        }
        .background(.black)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

#Preview {
    OnBoardTabView(viewModel: OnBoardItems())
}
