//
//  OnboardSettingsView.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 16.06.24.
//

import SwiftUI

struct OnboardSettingsView: View {
    @ObservedObject var viewModel: OnBoardItems
    @EnvironmentObject var settings: SettingsView.SettingsViewModel
    var body: some View {
        ZStack {
            SettingsView()
            VStack {
                Spacer()
                Button("Allow Notifications") {
                    Task {
                        try await viewModel.requestNotificationPermission()
                    }
                }
                .buttonStyle(.borderedProminent)
                Spacer()
                Button {
                    viewModel.isOnboarding()
                } label: {
                    Text("Finish")
                        .frame(width: 120)
                        .font(.title3.bold())
                }
                .buttonStyle(BorderedProminentButtonStyle())
//                .disabled(settings.companyName.count < 3 || settings.workHours == 0)
                .disabled(settings.companyName.count < 3)
            }
            .padding(.bottom, 30)
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    OnboardSettingsView(viewModel: OnBoardItems())
        .environmentObject(SettingsView.SettingsViewModel())
}
