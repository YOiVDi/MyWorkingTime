//
//  CreateNewDay.swift
//  MyWorkingTime
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
                Form {
                    Section {
                        Text("Company name: \(viewModel.userSettings?.companyName ?? "")")
                        
                        DatePicker("Choose a day: ", selection: $viewModel.date, displayedComponents: .date)
                        
                        
                        Picker("Working hour's", selection: $viewModel.workingHours) {
                            ForEach(0..<9) {
                                Text("\($0)")
                            }
                        }
                    } footer: {
                        Text("When you create a new day with a specific date, you can add check-ins, check-outs, and pauses after the day is created. Simply click on the day you created in the upper right corner via the edit button, and you will be able to edit that day. From there, you can update your check-in and check-out times, as well as add pauses.")
                    }
                }
                HStack {
                    Spacer()
                    Button("Create day") {
                        viewModel.creatingDayOfUserChoice(dismiss)
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .shadow(color: .black, radius: 3, x: -1, y: 1)
                    Spacer()
                }
            }
            .navigationTitle("New working day")
            .onAppear {viewModel.checkUserDefaults()}
        }
    }
}

#Preview {
    CreateNewDayView(viewModel: WorkingDaysView.ViewModel())
}
