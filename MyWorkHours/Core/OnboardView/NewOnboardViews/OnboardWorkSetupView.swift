//
//  OnboardWorkSetup.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 28.12.25.
//

import SwiftUI

struct OnboardWorkSetupView: View {
    @ObservedObject var onboardViewModel: OnboardViewModel
    
    var body: some View {
        VStack(spacing: 16) {

            // MARK: - Shift setup
            OnboardSetupWork(companyName: $onboardViewModel.initSettings.companyName, startShift: $onboardViewModel.initSettings.startShift, endShift: $onboardViewModel.initSettings.endShift, pause: $onboardViewModel.initSettings.pause, workOnWeekend: $onboardViewModel.initSettings.workOnWeekend, saturday: $onboardViewModel.initSettings.saturday, startInSaturday: $onboardViewModel.initSettings.startInSaturday, endInSaturday: $onboardViewModel.initSettings.endInSaturday, pauseSaturday: $onboardViewModel.initSettings.pauseSaturday, sunday: $onboardViewModel.initSettings.sunday, startInSunday: $onboardViewModel.initSettings.startInSunday, endInSunday: $onboardViewModel.initSettings.endInSunday, pauseSunday: $onboardViewModel.initSettings.pauseSunday)
                .padding(.horizontal)
            Spacer()
            
            Button {
                onboardViewModel.finishOnBording()
            } label: {
                Text("Finish Setup")
                    .frame(maxWidth: .infinity, maxHeight: 30)
                    .bold()
                    .foregroundStyle(Color.white)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .padding(.top, 100)
        .navigationTitle("Shift Setup")
    }
}

#Preview {
    OnboardWorkSetupView(onboardViewModel: OnboardViewModel(userDefaultsStore: UserDefaultsStore()))
}
