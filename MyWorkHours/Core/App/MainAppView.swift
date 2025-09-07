//
//  AppView.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 12.06.24.
//

import CoreData
import SwiftUI

struct MainAppView: View {
    @StateObject var viewModel = OnBoardItems()
    let persistenceController: PersistenceController
    var body: some View {
        Group {
            if !viewModel.finishOnboarding {
                OnBoardTabView(viewModel: viewModel)
                    .transition(.move(edge: .bottom))
            } else {
                WorkDaysTabView(persistenceController: persistenceController)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeIn(duration: 0.5), value: viewModel.finishOnboarding)
    }
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
}

#Preview {
    let persistenceController = PersistenceController.shared
    return MainAppView(persistenceController: persistenceController)
}
