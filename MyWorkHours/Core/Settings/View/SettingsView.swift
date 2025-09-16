//
//  MeView.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 17.12.23.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    // MARK: Properties
//    @StateObject var viewModel = SettingsViewModel()
    @EnvironmentObject var viewModel: SettingsViewModel
    
    // MARK: Body
    var body: some View {
        //        NavigationView {
        Form {
            Section ("Work Information") {
                TextField("Company name", text: $viewModel.companyName)
                    .autocorrectionDisabled()
                    .trimmedString($viewModel.companyName)
                DatePicker("Start Shift", selection: $viewModel.startShift, displayedComponents: .hourAndMinute)
                DatePicker("End Shift", selection: $viewModel.endShift, displayedComponents: .hourAndMinute)
            }
            
            Section("Weekend's") {
                Toggle("Work on weekends", isOn: $viewModel.workOnWeekends)
                
                if viewModel.workOnWeekends {
                    Toggle("Saturday", isOn: $viewModel.workOnSaturday)
                    if viewModel.workOnSaturday {
                        DatePicker("Start Shift", selection: $viewModel.startInSaturday, displayedComponents: .hourAndMinute)
                        DatePicker("End Shift", selection: $viewModel.endInSaturday, displayedComponents: .hourAndMinute)
                    }
                    Toggle("Sunday", isOn: $viewModel.workOnSunday)
                    if viewModel.workOnSunday {
                        DatePicker("Start Shift", selection: $viewModel.startInSunday, displayedComponents: .hourAndMinute)
                        DatePicker("End Shift", selection: $viewModel.endInSunday, displayedComponents: .hourAndMinute)
                    }
                }
            }
            
            /// Need to be fix.
            //                    Section("Holiday's") {
            //                        Toggle("Holiday's", isOn: $viewModel.workOnHolidays)
            //                        if viewModel.workOnHolidays {
            //                            Picker("Work hour's", selection: $viewModel.holidaysHours) {
            //                                ForEach(0..<13) {
            //                                    Text("\($0)h")
            //                                }
            //                            }
            //                        }
            //                    }
            //                }
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
        SettingsView()
        .environmentObject(SettingsView.SettingsViewModel())
}
