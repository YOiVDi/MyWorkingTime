//
//  EditSheet.swift
//  MyWorkTime
//
//  Created by Yordan Dimitrov on 09.05.24.
//

import SwiftUI

struct EditSheet: View {
    @State var model: WorkingDay
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
                    if model.arrPause.isEmpty { // if array is empty
                        ContentUnavailableView("You have no pauses.", systemImage: "doc.fill", description: Text("To add pause return back to detail view and use, a 'Add Pause' button."))
                    } else { // Showing if array is not empty
                        ForEach(model.arrPause, id: \.self) { pause in
                            HStack(spacing: 10) {
                                Image(systemName: pause == viewModel.selectedPause ? "checkmark.circle" : "circle")
                                    .foregroundStyle(.blue)
                                Text("Start: \(pause.wrappedStartPause.formatted(date: .omitted, time: .shortened))")
                                Spacer()
                                Text("Finish: \(pause.wrappedFinishPause.formatted(date: .omitted, time: .shortened))")
                            }
                            .onTapGesture {
                                viewModel.selectedPause(pause: pause)
                                print(model.arrPause)
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
                        Button("Save") {
                            viewModel.onSave()
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                        .shadow(color: .black, radius: 3, x: -1, y: 1)
                        Spacer()
                    }
                }
                .onAppear {
                    viewModel.newWorkingTime = Int(model.workingHours)
                }
                .onDisappear {
                    viewModel.selectedPause = nil
                }
            .navigationTitle("Updating Details")
        }
    }
}

#Preview {
    EditSheet(model: PersistenceController.preview, viewModel: DetailView.ViewModel(model: WorkingDay()))
}
