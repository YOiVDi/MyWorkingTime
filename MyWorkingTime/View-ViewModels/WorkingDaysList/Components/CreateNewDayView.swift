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
            Form {
                Text("Company name: \(viewModel.userSettings?.companyName ?? "")")
                
                DatePicker("Choose a day: ", selection: $viewModel.date, displayedComponents: .date)
                
                
                Picker("Working hour's", selection: $viewModel.workingHours) {
                    ForEach(0..<9) {
                        Text("\($0)")
                    }
                }
                
                Button("Create day") {
                    viewModel.creatingDayOfUserChoice(dismiss)
                }
            }
            .navigationTitle("New working day")
        }
    }
}

#Preview {
    CreateNewDayView(viewModel: WorkingDaysView.ViewModel())
}
