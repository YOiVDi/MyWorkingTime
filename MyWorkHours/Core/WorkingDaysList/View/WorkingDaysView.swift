//
//  WorkingDaysList.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 17.12.23.
//

import CoreData
import SwiftUI

struct WorkingDaysView: View {
    
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
                    WorkingDaysListView(viewModel: viewModel)
                }
            }
            .animation(.easeInOut, value: viewModel.workingDaysList.isEmpty)
            .frame(maxHeight: .infinity)
            .navigationTitle("Working Hours")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
    
    init(persistenceController: PersistenceController) {
        _viewModel = StateObject(wrappedValue: ViewModel(persistenceController: persistenceController))
    }
}

#Preview {
    let persistenceController = PersistenceController.shared
    return WorkingDaysView(persistenceController: persistenceController)
}
