//
//  EditSheet.swift
//  MyWorkTime
//
//  Created by Yordan Dimitrov on 09.05.24.
//

import SwiftUI

struct EditSheetView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DetailScreen.ViewModel
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section("Check-In and Check-Out Details") {
                        HStack {
                            Text("Check-In: ")
                                .frame(width: 120, alignment: .leading)
                            Spacer()
                            DatePicker("Check-In: ", selection: $viewModel.checkIn)
                                .labelsHidden()
                        }.frame(maxWidth: .infinity)
                        
                        HStack {
                            Text("Check-Out: ")
                                .frame(width: 120, alignment: .leading)
                            DatePicker("Check-Out: ", selection: $viewModel.checkOut)
                                .labelsHidden()
                        }
                        
                    }
                    Group {
                        if viewModel.addNewPause {
                            Section("Add new pause") {
                                HStack {
                                    Text("Pause Begin: ")
                                        .frame(width: 120, alignment: .leading)
                                    DatePicker("Pause Begin: ", selection: $viewModel.pauseBegin)
                                        .labelsHidden()
                                }
                                
                                HStack {
                                    Text("Pause End: ")
                                        .frame(width: 120, alignment: .leading)
                                    DatePicker("Pause End: ", selection: $viewModel.pauseEnd)
                                        .labelsHidden()
                                }
                                VStack {
                                    Text(viewModel.pauseDescription).foregroundColor(.red.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                    HStack {
                                        Spacer()
                                        Button("Add pause") {
                                            viewModel.addPause()
                                            viewModel.addNewPause.toggle()
                                        }
                                        .disabled(!viewModel.pauseDescription.isEmpty)
                                        .buttonStyle(.borderedProminent)
                                        Spacer()
                                    }
                                }
                            }
                        } else if viewModel.modelPauses.isEmpty { // if array is empty
                            ContentUnavailableView("You have no pauses.", systemImage: "doc.fill", description: Text("To add pause click on \(Image(systemName: "plus.circle.fill")) button."))
                                .transition(.opacity)
                        } else { // Showing if array is not empty
                            Section("\(viewModel.modelPauses.count <= 1 ? "Pause" : "Pauses")") {
                                ForEach(viewModel.modelPauses, id: \.id) { pause in
                                    HStack {
                                        Image(systemName: pause.id == viewModel.selectedPause?.id ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(.blue)
                                        Text("Start: \(pause.startPause.formatted(date: .omitted, time: .shortened))")
                                        Text("Finish: \(pause.finishPause.formatted(date: .omitted, time: .shortened))")
                                    }
                                    .onTapGesture {
                                        withAnimation {
                                            viewModel.selectPause(pause)
                                        }
                                    }
                                    .swipeActions  {
                                        Button {
                                            withAnimation {
                                                viewModel.selectedPause = pause
                                                viewModel.deletePause()
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                                .tint(.red)
                                        }
                                    }
                                }
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.vertical)
                    
                }
                .animation(.easeInOut(duration: 5), value: viewModel.addNewPause)
                .animation(.easeInOut(duration: 5), value: viewModel.modelPauses.count)
                .padding()
                .scrollContentBackground(.hidden)
                .background(colorScheme == .dark ? Color(UIColor.black) : Color(UIColor.white))
                // Button to save all changes
                HStack {
                    Spacer()
                    Button("Update") {
                        withAnimation {
                            viewModel.update()
                            dismiss()
                        }
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .shadow(color: .black, radius: 3, x: -1, y: 1)
                    Spacer()
                }
            }
            .background(colorScheme == .dark ? Color(UIColor.black) : Color(UIColor.white))
            .animation(.easeInOut, value: viewModel.selectedPause)
            .onAppear {
                viewModel.dateOfWorkDay()
                print("pauseStartEdit: \(viewModel.pauseBegin), pauseFinishEdit: \(viewModel.pauseEnd)")
            }
            .onDisappear {
                viewModel.selectedPause = nil
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
                    withAnimation(.easeInOut) {
                        withAnimation {
                            viewModel.buttons()
                        }
                    }
                    .disabled(viewModel.disableAddPause)
                }
            }
            .navigationTitle("Edit \(viewModel.model.date.formatted(date: .abbreviated, time: .omitted))")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    EditSheetView(viewModel: DetailScreen.ViewModel(model: WorkDay.mock, workingDayPauseService: WorkingDayPauseService(persistenceController: PersistenceController.shared, workingDaysQueryServices: WorkingDaysQueryService(persistenceController: PersistenceController.shared)), workDayService: WorkingDaysService(queryService: WorkingDaysQueryService(persistenceController: PersistenceController.shared), persistenceController: PersistenceController.shared), refreshWorkDayInArr: { _ in nil} ))
}
