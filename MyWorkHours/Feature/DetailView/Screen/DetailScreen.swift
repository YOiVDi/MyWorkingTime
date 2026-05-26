//
//  DayInformation.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 26.12.23.
//

import SwiftUI

struct DetailScreen: View {
    
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
                    workHoursSection
                
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
        .onAppear(perform: {
            viewModel.calculatedWorkedTime()
        })
        
        
        // MARK: Edited Sheet
        .sheet(isPresented: $viewModel.onChange) {
            EditSheetView(viewModel: viewModel)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    withAnimation {
                        viewModel.onChange.toggle()
                    }
                } label: {
                    Text("Edit")
                }
            }
        }
        .navigationTitle("\(viewModel.model.date.formatted(.dateTime.day().month()))")
    }
    
    // MARK: - Private compute properties
    private var companySection: some View {
        Section("Company") {
            Text(viewModel.model.companyName)
                .font(.body)
                .fontWeight(.semibold)
        }
    }
    
    private var workHoursSection: some View {
        Section("Day Working Hour's") {
            Text(viewModel.model.workHours >= 9 ? viewModel.calculateWorkTimeFromMinutes() : "\(viewModel.model.workHours)")
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
        Section("\(viewModel.modelPauses.count <= 1 ? "Pause" : "Pauses")") {
            Group {
                ForEach(viewModel.modelPauses, id: \.self) { pause in
                    HStack {
                        Text("Start: \(pause.startPause.formatted(date: .omitted, time: .standard))")
                        Text("Finish: \(pause.finishPause.formatted(date: .omitted, time: .standard))")
                    }
                }
                
                if viewModel.modelPauses.count == 0 {
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
    init(viewModel: DetailScreen.ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    NavigationView {
        DetailScreen(viewModel: DetailScreen.ViewModel(model: WorkDay.mock, workingDayPauseService: WorkingDayPauseService(persistenceController: PersistenceController.shared, workingDaysQueryServices: WorkingDaysQueryService(persistenceController: PersistenceController.shared)), workDayService: WorkingDaysService(queryService: WorkingDaysQueryService(persistenceController: PersistenceController.shared), persistenceController: PersistenceController.shared), refreshWorkDayInArr: { _ in nil }))
    }
}
