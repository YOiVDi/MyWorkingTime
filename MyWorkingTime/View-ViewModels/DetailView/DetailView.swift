//
//  DayInformation.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 26.12.23.
//

import SwiftUI

struct DetailView: View {
    
    // MARK: Properties
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
        List {
            Group {
                // Company section
                companySection
                // WorkingHours section
                workingHoursSection
                // Pause Section
                pauseSection
            }
            //            .listRowSeparator(.hidden)
        }
        .listRowSpacing(10)
        .scrollContentBackground(.hidden)
        .scrollBounceBehavior(.basedOnSize)
            HStack {
                Spacer()
                Button {
                    viewModel.addPause(for: viewModel.model)
                } label: {
                    Text("Add Pause")
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .shadow(color: .black, radius: 3, x: -1, y: 1)
                Spacer()
            }
            .disabled(viewModel.model.arrPause.count >= 5)
            .padding(.bottom, 80)
    }
        
        
        // MARK: Edited Sheet
        .sheet(isPresented: $viewModel.onChange) {
            EditSheet(model: viewModel.model, viewModel: viewModel)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    withAnimation {
                        viewModel.onChange = true
                    }
                } label: {
                    Text("Edit")
                }
            }
        }
        .navigationTitle("\(viewModel.model.wrappedDate.formatted(.dateTime.day().month()))")
        .onDisappear(perform: {
            dismiss()
        })
    }
    
    private var companySection: some View {
        Section("Company") {
            Text(viewModel.model.wrappedCompanyname)
                .font(.body)
                .fontWeight(.semibold)
        }
    }
    
    private var workingHoursSection: some View {
        Section("Working Hour's") {
//            Text("\(model.wrappedWorkingHours.formatted(date: .omitted, time: .shortened))")
            Text("\(viewModel.model.WrappedWorkingHours)")
                .font(.body)
                .fontWeight(.semibold)
        }
    }
    
    private var pauseSection: some View {
            Section("Pause") {
                if viewModel.model.arrPause.count != 0  {
                    ForEach(0..<viewModel.model.arrPause.count, id: \.self) { index in
                        HStack {
                            Text("Start: \(viewModel.model.arrPause[index].wrappedStartPause.formatted(date: .omitted, time: .shortened))")
                                .font(.body)
                                .fontWeight(.semibold)
                            Text("Finish: \(viewModel.model.arrPause[index].wrappedFinishPause.formatted(date: .omitted, time: .shortened))")
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                        .swipeActions {
                            let pause = viewModel.model.arrPause[index]
                            Button("delete", role: .destructive) {
                                viewModel.deletePause(workingDay: viewModel.model, pause: pause)
                            }
                        }
                    }
                }
            }
    }
    init(model: WorkingDay) {
        _dismiss = Environment(\.dismiss)
        _viewModel = StateObject(wrappedValue: ViewModel(model: model))
    }
}

#Preview {
    NavigationView {
        
        DetailView(model: PersistenceController.preview)
    }
}
