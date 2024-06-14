//
//  OnboardItemView.swift
//  MyWorkingTime
//
//  Created by Yordan Dimitrov on 10.06.24.
//

import SwiftUI

struct OnboardItemView: View {
    @ObservedObject var viewModel: OnBoardItems
    @State var showButton = false
    let item: OnboardItem
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack {
                Image(item.image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .clipShape(.rect(cornerRadius: 10))
                    .padding(.horizontal)
                Text(item.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                    .padding(.horizontal)
                    .foregroundColor(.white)
                Text(item.content)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                    .padding(.horizontal)
                    .foregroundColor(.gray)
                    .font(.body.bold())
                if item == viewModel.onboardItems.last {
                    Button {
                        viewModel.isOnboarding()
                    } label: {
                        Text("Finish")
                            .font(.title3.bold())
                            .padding(.horizontal)
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .padding(.top)
                }
                Spacer()
            }
            .padding(.top, 150)
        }
    }
}

#Preview {
    OnboardItemView(viewModel: OnBoardItems(), item: .dummyItem)
}
