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
                    // Company Section
                    companySection
                    
                    // WorkingHours Section
                    workingHoursSection
                
                    // Check-In Section
                    checkIn
                    
                    // Check-Out Section
                    checkOut
                    
                    // Pause Section
                    pauseSection
                    
                    // WorkingTime Calculation Section
                    endOfTheDayTime
                }
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
                        viewModel.editButton()
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
    
    // MARK: - Private compute properties
    private var companySection: some View {
        Section("Company") {
            Text(viewModel.model.wrappedCompanyname)
                .font(.body)
                .fontWeight(.semibold)
        }
    }
    
    private var workingHoursSection: some View {
        Section("Day Working Hour's") {
            Text("\(viewModel.model.wrappedWorkingHours)")
                .font(.body)
                .fontWeight(.semibold)
        }
    }
    
    private var checkIn: some View {
        Section("Check-In") {
            Group {
                if let checkIn = viewModel.model.checkIn {
                    Text("\(checkIn.formatted(.dateTime.day().month().year().hour().minute().second()))")
                } else {
                    Text("There are no check-In data")
                }
            }
            .font(.body)
            .fontWeight(.semibold)
        }
    }
    
    private var checkOut: some View {
        Section("Check-Out") {
            Group {
                if let checkOut = viewModel.model.checkOut  {
                    Text("\(checkOut.formatted(.dateTime.day().month().year().hour().minute().second()))")
                } else {
                    Text("There are no check-out data")
                }
            }
            .font(.body)
            .fontWeight(.semibold)
        }
    }
    
    private var pauseSection: some View {
        Section("\(viewModel.model.arrPause.count <= 1 ? "Pause" : "Pauses")") {
            Group {
                ForEach(viewModel.model.arrPause, id: \.self) { pause in
                    HStack {
                        Text("Start: \(pause.wrappedStartPause.formatted(date: .omitted, time: .standard))")
                        Text("Finish: \(pause.wrappedFinishPause.formatted(date: .omitted, time: .standard))")
                    }
                }
                
                if viewModel.model.arrPause.count == 0 {
                    Text("You can edit the day and manually add the breaks.")
                }
            }
            .font(.body)
            .fontWeight(.semibold)
        }
    }
    
    private var endOfTheDayTime: some View {
        Section("Total Working Hour's") {
            Text(viewModel.workedTime)
                .font(.body)
                .fontWeight(.semibold)
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
