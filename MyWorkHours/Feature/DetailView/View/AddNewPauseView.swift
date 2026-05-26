//
//  AddNewPauseView.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 09.09.25.
//

import SwiftUI

struct AddNewPauseView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DetailScreen.ViewModel
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("New Start", selection: $viewModel.pauseBegin)
                DatePicker("New Finish", selection: $viewModel.pauseEnd)
                
                Button("Add Pause") {
//                    viewModel.addPause(for: viewModel.model) <--  FIX
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    init(viewModel: DetailScreen.ViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
}

#Preview {
    AddNewPauseView(viewModel: DetailScreen.ViewModel(model: WorkDay.mock, workingDayPauseService: WorkingDayPauseService(persistenceController: PersistenceController.shared, workingDaysQueryServices: WorkingDaysQueryService(persistenceController: PersistenceController.shared)), workDayService: WorkingDaysService(queryService: WorkingDaysQueryService(persistenceController: PersistenceController.shared), persistenceController: PersistenceController.shared), refreshWorkDayInArr: { _ in nil }))
}
