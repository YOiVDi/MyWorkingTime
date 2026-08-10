//
//  AppView.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 12.06.24.
//

import CoreData
import SwiftUI

struct MainAppView: View {
    @StateObject var onboardViewModel: OnboardViewModel
    @ObservedObject var userStatusStore: UserStatusStore
    let servicesContainer: ServicesContainer
    var body: some View {
        Group {
            if !onboardViewModel.finishOnboarding {
//                OnBoardTabView(viewModel: onboardViewModel)
                OnbordingScreen(onboardViewModel: onboardViewModel)
                    .transition(.move(edge: .bottom))
            } else {
                WorkDaysTabView(servicesContainer, userStatusStore: userStatusStore)
                    .transition(.move(edge: .bottom))
//                PurchaseView(userStatusStore: userStatusStore)
            }
        }
        .animation(.easeIn(duration: 0.5), value: onboardViewModel.finishOnboarding)
    }
    
    init(_ servicesContainer: ServicesContainer, _ userStatusStore: UserStatusStore) {
        self.servicesContainer = servicesContainer
        _userStatusStore = ObservedObject(wrappedValue: userStatusStore)
        _onboardViewModel = StateObject(wrappedValue: OnboardViewModel(userDefaultsStore: servicesContainer.userDefaultsService, userSettingsStore: servicesContainer.userSettingsStore))
    }
}

#Preview {
    return MainAppView(ServicesContainer(persistenceController: PersistenceController.shared), UserStatusStore(userDefaultsStore: UserDefaultsStore()))
}
