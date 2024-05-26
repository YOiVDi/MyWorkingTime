//
//  EditSheet.swift
//  MyWorkTime
//
//  Created by Yordan Dimitrov on 09.05.24.
//

import SwiftUI

struct EditSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DetailView.ViewModel
    var body: some View {
        NavigationView {
            List {
                Picker("WorkingHours's", selection: $viewModel.newWorkingTime) {
                    ForEach(0..<9) {
                        Text("\($0)")
                    }
                }
                if viewModel.model.arrPause.isEmpty { // if array is empty
                    ContentUnavailableView("You have no pauses.", systemImage: "doc.fill", description: Text("To add pause click on \(Image(systemName: "plus.circle.fill")) button."))
                } else { // Showing if array is not empty
                    Section("\(viewModel.model.arrPause.count <= 1 ? "Pause" : "Pauses")") {
                        ForEach(viewModel.model.arrPause, id: \.id) { pause in
                            HStack {
                                Image(systemName: pause.id == viewModel.selectedPause?.id ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(.blue)
                                Text("Start: \(pause.wrappedStartPause.formatted(date: .omitted, time: .shortened))")
                                Text("Finish: \(pause.wrappedFinishPause.formatted(date: .omitted, time: .shortened))")
                            }
                            .onTapGesture {
                                if viewModel.selectedPause?.id == pause.id {
                                    viewModel.selectedPause = nil
                                } else {
                                    viewModel.selectedPause = pause
                                    viewModel.pauseStartEdit = pause.wrappedStartPause
                                    viewModel.pauseFinishEdit = pause.wrappedFinishPause
                                }
                            }
                        }
                    }
                }
                
                // Edit pause time
                if viewModel.selectedPause != nil {
                    VStack {
                        DatePicker("New Start", selection: $viewModel.pauseStartEdit, displayedComponents: .hourAndMinute)
                        DatePicker("New Finish", selection: $viewModel.pauseFinishEdit, displayedComponents: .hourAndMinute)
                    }
                }
                
                // Button to save all changes
                HStack {
                    Spacer()
                    Button("Update") {
                        viewModel.update()
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .shadow(color: .black, radius: 3, x: -1, y: 1)
                    Spacer()
                }
            }
            .onAppear {
                viewModel.newWorkingTime = Int(viewModel.model.workingHours)
            }
            .onDisappear {
                viewModel.selectedPause = nil
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    buttons
                }
            }
        }
        .navigationTitle("Editing \(viewModel.model.wrappedDate.formatted(date: .abbreviated, time: .omitted))")
    }
    private var buttons: some View {
        if (viewModel.selectedPause != nil) {
            Button {
                viewModel.deletePause(pause: viewModel.selectedPause!)
                viewModel.selectedPause = nil
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } else {
            Button {
                viewModel.addPause(for: viewModel.model)
            } label: {
                Label("Add", systemImage: "plus.circle.fill")
            }
        }
    }
}
    
    #Preview {
        EditSheet(viewModel: DetailView.ViewModel(model: WorkingDay()))
    }
