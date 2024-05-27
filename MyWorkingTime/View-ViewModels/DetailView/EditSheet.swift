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
                                viewModel.selectPause(pause)
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
            .animation(.easeInOut, value: viewModel.selectedPause)
            .onAppear {
                viewModel.newWorkingTime = Int(viewModel.model.workingHours)
            }
            .onDisappear {
                viewModel.selectedPause = nil
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
                }
            }
            .navigationTitle("Edit \(viewModel.model.wrappedDate.formatted(date: .abbreviated, time: .omitted))")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    EditSheet(viewModel: DetailView.ViewModel(model: WorkingDay()))
}
