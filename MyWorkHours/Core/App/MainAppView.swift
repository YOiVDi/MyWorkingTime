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
    let persistenceController: PersistenceController
    var body: some View {
        Group {
            if !onboardViewModel.finishOnboarding {
                OnBoardTabView(viewModel: onboardViewModel)
                    .transition(.move(edge: .bottom))
            } else {
                WorkDaysTabView(persistenceController: persistenceController)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeIn(duration: 0.5), value: onboardViewModel.finishOnboarding)
    }
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
}

#Preview {
    let persistenceController = PersistenceController.shared
    return MainAppView(persistenceController: persistenceController)
}
