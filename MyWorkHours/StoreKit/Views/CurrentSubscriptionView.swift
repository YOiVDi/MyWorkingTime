//
//  CurrentSubscriptionView.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 11.10.25.
//

import SwiftUI

struct CurrentSubscriptionView: View {
    @ObservedObject var viewModel: PurchaseViewModel
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),   // deep navy
                    Color(red: 0.18, green: 0.00, blue: 0.35)    // rich purple
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
                .ignoresSafeArea()
            VStack {
                // MARK: - Title
                VStack {
                    Image(systemName: "crown")
                        .font(.system(size: 50)).bold()
                        .foregroundStyle(.white)
                    Group {
                        Text("You are Premium")
                    }
                    .font(.largeTitle).bold()
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                }
                // MARK: - Current Subscription Info
                if let current = viewModel.userCurrentSubscription {
                    VStack(spacing: 10) {
                        Text("Your current subscription:")
                            .font(.headline)
                        Text(current.displayName + " - " + current.displayPrice)
                            .font(.title2).bold()
                            .foregroundStyle(.green)
                        if viewModel.subscriptionExpirationDate != nil {
                            Text(viewModel.renewMessage)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal)
                        }
                        
                        Button("Manage Subscription") {
                            Task { await viewModel.manageSubscription() }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)
                    }
                    .padding(.top, 30)
                }
            }
            .animation(.easeInOut, value: viewModel.renewMessage)
        }
    }
}

#Preview {
    CurrentSubscriptionView(viewModel: PurchaseViewModel(userStatusStore: UserStatusStore(userDefaultsStore: UserDefaultsStore())))
}
