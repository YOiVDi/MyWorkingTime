//
//  CreateNewDay.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 19.05.24.
//

import SwiftUI

struct CreateNewDayView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WorkingDaysView.ViewModel
    var body: some View {
        NavigationView {
                VStack {
                    HStack {
                        Text("Company name: ")
                            .fontWeight(.semibold)
                        Text("\(viewModel.userSettings?.companyName ?? "")")
                        Spacer()
                    }
                    
                    HStack {
                        Text("Choose a day: ")
                            .fontWeight(.semibold)
                        DatePicker("Choose a day: ", selection: $viewModel.date, displayedComponents: .date)
                            .labelsHidden()
                        Spacer()
                    }
                    
                    VStack {
                        Text("Working hour's: ")
                            .fontWeight(.semibold)
                        DatePicker("Start Shift", selection: $viewModel.startShift, displayedComponents: .hourAndMinute)
                        DatePicker("End Shift", selection: $viewModel.endShift, displayedComponents: .hourAndMinute)
                        Spacer()
                    }
                    Text("When you create a new day with a specific date, you can add check-ins, check-outs, and pauses after the day is created. Simply click on the day you created in the upper right corner via the edit button, and you will be able to edit that day. From there, you can update your check-in and check-out times, as well as add pauses.")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Create day") {
                        viewModel.creatingDayOfUserChoice(dismiss)
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .shadow(color: .black, radius: 3, x: -1, y: 1)
                    Spacer()
                }
            .padding(.horizontal, 20)
            .navigationTitle("New working day")
            .onAppear {viewModel.checkUserDefaults()}
        }
    }
}

#Preview {
    let persistenceController = PersistenceController.shared
    return CreateNewDayView(viewModel: WorkingDaysView.ViewModel(persistenceController: persistenceController))
}
