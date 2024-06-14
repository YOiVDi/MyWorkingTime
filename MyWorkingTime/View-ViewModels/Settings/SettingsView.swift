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
    @StateObject var viewModel = SettingsViewModel()
    
    // MARK: Body
    var body: some View {
        NavigationView {
                Form {
                    Section ("Work Information") {
                        TextField("Company name", text: $viewModel.companyName)
                            .autocorrectionDisabled()
                            .trimmedString($viewModel.companyName)
//                        
                        Picker("Work hour's", selection: $viewModel.workHours) {
                            ForEach(0..<13) {
                                Text("\($0)h")
                            }
                        }
                    }
                    
                    Section("Weekend's") {
                        Toggle("Work on weekends", isOn: $viewModel.workOnWeekends)
                        
                        if viewModel.workOnWeekends {
                            Toggle("Saturday", isOn: $viewModel.workOnSaturday)
                            if viewModel.workOnSaturday {
                                Picker("Work hour's", selection: $viewModel.saturdayHours) {
                                    ForEach(0..<13) {
                                        Text("\($0)h")
                                    }
                                }
                            }
                            Toggle("Sunday", isOn: $viewModel.workOnSunday)
                            if viewModel.workOnSunday {
                                Picker("Work hour's", selection: $viewModel.sundayHours) {
                                    ForEach(0..<13) {
                                        Text("\($0)h")
                                    }
                                }
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
                }
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
}
