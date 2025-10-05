//
//  WorkingDaysList.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 17.12.23.
//

import CoreData
import SwiftUI

struct WorkDaysScreen: View {
    
    // MARK: Properties
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            // MARK: - Main Stack
            ZStack(alignment: .bottomTrailing) {
                if viewModel.workingDaysList.isEmpty {
                    UnavailableView(viewModel: viewModel)
                } else {
                    // MARK: - ListView
                    WorkDaysListView(viewModel: viewModel)
                }
            }
            .animation(.easeInOut, value: viewModel.workingDaysList.isEmpty)
            .frame(maxHeight: .infinity)
            .navigationTitle("Working Hours")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.checkUserDefaults()
        }
    }
    
    init(persistenceController: PersistenceController, userStatusManager: UserStatusManager) {
        _viewModel = StateObject(wrappedValue: ViewModel(persistenceController: persistenceController, userStatusManager: userStatusManager))
    }
}

#Preview {
    let persistenceController = PersistenceController.shared
    let userStatusManager = UserStatusManager()
    WorkDaysScreen(persistenceController: persistenceController, userStatusManager: userStatusManager)
}
