//
//  SubscriptionScreen.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 11.10.25.
//

import SwiftUI

struct SubscriptionScreen: View {
    @ObservedObject var viewModel: PurchaseViewModel
    var body: some View {
        Group {
            if viewModel.userStatus == .basic {
                PurchaseView(viewModel: viewModel)
                    .transition(.slide)
            } else {
                CurrentSubscriptionView(viewModel: viewModel)
                    .transition(.slide)
            }
        }
        .animation(.easeInOut, value: viewModel.userStatus)
    }
}

#Preview {
    SubscriptionScreen(viewModel: PurchaseViewModel(userStatusManager: UserStatusStore(userDefaultsStore: UserDefaultsStore())))
}
