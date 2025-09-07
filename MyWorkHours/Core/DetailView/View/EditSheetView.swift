//
//  EditSheet.swift
//  MyWorkTime
//
//  Created by Yordan Dimitrov on 09.05.24.
//

import SwiftUI

struct EditSheetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DetailView.ViewModel
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section("Working Day Detail's") {
                        HStack {
                            Text("WorkingHour's: ")
                            Spacer()
                            Picker("WorkingHour's", selection: $viewModel.newWorkingTime) {
                                ForEach(0..<9) {
                                    Text("\($0)")
                                }
                            }
                            .labelsHidden()
                        }
                        
                        DatePicker("Check-In: ", selection: $viewModel.checkIn)
                        
                        DatePicker("Check-Out: ", selection: $viewModel.checkOut)
                        
                    }
                    if viewModel.modelPauses.isEmpty { // if array is empty
                        ContentUnavailableView("You have no pauses.", systemImage: "doc.fill", description: Text("To add pause click on \(Image(systemName: "plus.circle.fill")) button."))
                    } else { // Showing if array is not empty
                        Section("\(viewModel.modelPauses.count <= 1 ? "Pause" : "Pauses")") {
                            ForEach(viewModel.modelPauses, id: \.self) { pause in
                                HStack {
                                    Image(systemName: pause.id == viewModel.selectedPause?.id ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(.blue)
                                    Text("Start: \(pause.wrappedStartPause.formatted(date: .omitted, time: .shortened))")
                                    Text("Finish: \(pause.wrappedFinishPause.formatted(date: .omitted, time: .shortened))")
                                }
                                .onTapGesture {
                                    viewModel.selectPause(pause)
                                }
                                .swipeActions  {
                                    Button {
                                        viewModel.selectedPause = pause
                                        viewModel.deletePause()
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                            .tint(.red)
                                    }
                                }
                                // Edit pause time
                                if viewModel.selectedPause == pause {
                                    VStack {
                                        DatePicker("New Start", selection: $viewModel.pauseStartEdit)
                                        DatePicker("New Finish", selection: $viewModel.pauseFinishEdit)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                // Button to save all changes
                HStack {
                    Spacer()
                    Button("Update") {
                        viewModel.update()
                        dismiss()
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .shadow(color: .black, radius: 3, x: -1, y: 1)
                    Spacer()
                }
            }
            .animation(.easeInOut, value: viewModel.selectedPause)
            .onAppear {
                viewModel.newWorkingTime = Int(viewModel.model.workingHours)
                print("pauseStartEdit: \(viewModel.pauseStartEdit), pauseFinishEdit: \(viewModel.pauseFinishEdit)")
            }
            .onDisappear {
                viewModel.selectedPause = nil
                viewModel.modelPauses = viewModel.model.arrPause
                print("Disappear")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("Back")
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    viewModel.buttons()
                        .disabled(viewModel.disableAddPause)
                }
            }
            .navigationTitle("Edit \(viewModel.model.wrappedDate.formatted(date: .abbreviated, time: .omitted))")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let persistenceController = PersistenceController.shared
    return EditSheetView(viewModel: DetailView.ViewModel(model: WorkingDay(), modelPauses: [Pause](), persistenceController: persistenceController))
}
