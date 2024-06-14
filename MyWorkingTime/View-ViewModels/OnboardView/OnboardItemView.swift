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
                item.image
                    .font(.system(size: 200))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
                    .background(RadialGradient(gradient: Gradient(colors: [.blue, .white]), center: .center, startRadius: 5, endRadius: 500))
                    .clipShape(.rect(cornerRadius: 10))
                    .padding(.horizontal, 5)
                Text(item.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                    .padding(.horizontal)
                    .foregroundColor(.white)
                Text(item.content)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                    .padding(.horizontal)
                    .foregroundColor(.gray)
                    .font(.body.bold())
                    .minimumScaleFactor(0.5)
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
            .padding(.top, 100)
        }
    }
}

#Preview {
    OnboardItemView(viewModel: OnBoardItems(), item: .dummyItem)
}
