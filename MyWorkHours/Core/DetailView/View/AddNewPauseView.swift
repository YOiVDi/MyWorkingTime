//
//  AddNewPauseView.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 09.09.25.
//

import SwiftUI

struct AddNewPauseView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DetailView.ViewModel
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("New Start", selection: $viewModel.pauseBegin)
                DatePicker("New Finish", selection: $viewModel.pauseEnd)
                
                Button("Add Pause") {
                    viewModel.addPause(for: viewModel.model)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    init(viewModel: DetailView.ViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
}

#Preview {
    let preview = PersistenceController.preview
    AddNewPauseView(viewModel: DetailView.ViewModel(model: preview, persistenceController: PersistenceController.shared))
}
