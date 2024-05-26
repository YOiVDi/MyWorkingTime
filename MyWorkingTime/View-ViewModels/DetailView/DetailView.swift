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
        }
        
        
        // MARK: Edited Sheet
        .sheet(isPresented: $viewModel.onChange) {
            EditSheet(viewModel: viewModel)
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
            Text("\(viewModel.model.wrappedWorkingHours)")
                .font(.body)
                .fontWeight(.semibold)
            Text("Check-In: \(viewModel.model.wrappedCheckIn)")
                .lineLimit(1)
            Text("Check-Out: \(viewModel.model.wrappedCheckOut)")
                .lineLimit(1)
        }
    }
    
    private var pauseSection: some View {
        Section("Pause") {
            ForEach(viewModel.model.arrPause, id: \.id) { pause in
                HStack {
                    Text("Start: \(pause.wrappedStartPause.formatted(date: .omitted, time: .shortened))")
                        .font(.body)
                        .fontWeight(.semibold)
                    Text("Finish: \(pause.wrappedFinishPause.formatted(date: .omitted, time: .shortened))")
                        .font(.body)
                        .fontWeight(.semibold)
                }
            }
        }
    }
    init(model: WorkingDay) {
        _viewModel = StateObject(wrappedValue: ViewModel(model: model))
    }
}

#Preview {
    NavigationView {
        
        DetailView(model: PersistenceController.preview)
    }
}
