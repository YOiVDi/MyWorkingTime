//
//  AppView.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 12.06.24.
//

import CoreData
import SwiftUI

struct MainAppView: View {
    @StateObject var onboardViewModel = OnboardViewModel()
    @ObservedObject var userStatusManager: UserStatusManager
    let servicesContainer: ServicesContainer
    var body: some View {
        Group {
            if !onboardViewModel.finishOnboarding {
                OnBoardTabView(viewModel: onboardViewModel)
                    .transition(.move(edge: .bottom))
            } else {
                WorkDaysTabView(servicesContainer, userStatusManager: userStatusManager)
                    .transition(.move(edge: .bottom))
//                PurchaseView(userStatusManager: userStatusManager)
            }
        }
        .animation(.easeIn(duration: 0.5), value: onboardViewModel.finishOnboarding)
    }
    
    init(_ servicesContainer: ServicesContainer, _ userStatusManager: UserStatusManager) {
        self.servicesContainer = servicesContainer
        _userStatusManager = ObservedObject(wrappedValue: userStatusManager)
    }
}

#Preview {
    let servicesContainer = ServicesContainer()
    let userStatusManager = UserStatusManager()
    return MainAppView(servicesContainer, userStatusManager)
}
