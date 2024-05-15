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
    @State private var selectedPause: Pause?
    var body: some View {
        NavigationView {
                List {
                    Picker("WorkingHours's", selection: $viewModel.newWorkingTime) {
                        ForEach(0..<9) {
                            Text("\($0)")
                        }
                    }
                    if model.arrPause.isEmpty { // if array is empty
                        Text("Add pause")
                    } else { // Showing if array is not empty
                        ForEach(model.arrPause, id: \.self) { pause in
                            HStack(spacing: 10) {
                                Image(systemName: pause == selectedPause ? "checkmark.circle" : "circle")
                                    .foregroundStyle(.blue)
                                Text("Start: \(pause.wrappedStartPause.formatted(date: .omitted, time: .shortened))")
                                Spacer()
                                Text("Finish: \(pause.wrappedFinishPause.formatted(date: .omitted, time: .shortened))")
                            }
                            .onTapGesture {
                                selectedPause = pause
                            }
                        }
                    }
                    
                    // Edit pause time
                    if selectedPause != nil {
                        VStack {
                            DatePicker("New Start", selection: $viewModel.pauseStartEdit, displayedComponents: .hourAndMinute)
                            DatePicker("New Finish", selection: $viewModel.pauseFinishEdit, displayedComponents: .hourAndMinute)
                        }
                    }
                    
                    // Button to save all changes
                    HStack {
                        Spacer()
                        Button("Save") {
                            // Show error message or prevent submission
                            guard viewModel.pauseFinishEdit > viewModel.pauseStartEdit else {
                                print("Your Start of pause is bigger than finish pause.")
                                return
                            }
                            viewModel.update(model, pause: selectedPause)
                            selectedPause = nil
                            viewModel.onChange.toggle()
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                        .shadow(color: .black, radius: 3, x: -1, y: 1)
                        Spacer()
                    }
                }
            .navigationTitle("Updating Details")
        }
    }
}

#Preview {
    EditSheet(model: PersistenceController.preview, viewModel: DetailView.ViewModel())
}
