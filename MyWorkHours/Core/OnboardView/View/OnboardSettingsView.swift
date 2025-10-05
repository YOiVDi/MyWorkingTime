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
                    viewModel.isOnboarding()
                }
            }
    }
    
}

#Preview {
    let services = ServicesContainer()
    let userStatusManager = UserStatusManager()
    OnboardSettingsView(viewModel: OnboardViewModel())
        .environmentObject(SettingsView.SettingsViewModel(services, userStatusManager))
}
