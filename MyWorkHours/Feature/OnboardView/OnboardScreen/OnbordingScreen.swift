//
//  OnbordingScreen.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 28.12.25.
//

import SwiftUI

enum Destination {
    case first, second
}

struct OnbordingScreen: View {
    @ObservedObject var onboardViewModel: OnboardViewModel
    @State var path: [Destination] = []
    @State var screen: Destination = .first
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                OnboardWelcomeView()
                    .navigationDestination(for: Destination.self) { destination in
                        switch destination {
                        case .first: OnboardWelcomeView()
                        case .second: OnboardWorkSetupView(onboardViewModel: onboardViewModel)
                        }
                    }
                
                Button {
                    path.append(.second)
            } label: {
                Text("Get Started")
                    .frame(maxWidth: .infinity, maxHeight: 30)
                    .foregroundStyle(Color.white)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
    }
}
}

#Preview {
    OnbordingScreen(onboardViewModel: OnboardViewModel(userDefaultsStore: UserDefaultsStore()))
}
