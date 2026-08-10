//
//  OnboardSettingsView.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 16.06.24.
//

import SwiftUI

struct OnboardSettingsView: View {
    @ObservedObject var viewModel: OnboardViewModel
    @EnvironmentObject var settings: SettingsView.SettingsViewModel
    var body: some View {
            VStack {
                SettingsView(showFinishButton: true) {
                    viewModel.finishOnBording()
                }
            }
    }
    
}

#Preview {
    OnboardSettingsView(viewModel: OnboardViewModel(userDefaultsStore: UserDefaultsStore(), userSettingsStore: UserSettingsStore(userDefaultsStore: UserDefaultsStore())))
        .environmentObject(SettingsView.SettingsViewModel(ServicesContainer(persistenceController: PersistenceController.shared), UserStatusStore(userDefaultsStore: UserDefaultsStore())))
}
