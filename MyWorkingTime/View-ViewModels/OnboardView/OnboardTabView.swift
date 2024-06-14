//
//  OnBoardView.swift
//  MyWorkingTime
//
//  Created by Yordan Dimitrov on 10.06.24.
//

import SwiftUI

struct OnBoardView: View {
    @StateObject var viewModel = ViewModel()
    var body: some View {
        TabView {
            
            ForEach(viewModel.onboardItems, id: \.self) { item in
                
            }
        }
    }
}

#Preview {
    OnBoardView()
}
