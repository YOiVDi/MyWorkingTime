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
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = SettingsViewModel()
    
    // MARK: Body
    var body: some View {
        NavigationView {
                Form {
                    Section ("work information") {
                        TextField("Company name", text: $viewModel.userSettings.companyName)
                            .autocorrectionDisabled()
                            .onChange(of: viewModel.userSettings.companyName) {
                                viewModel.trimWhiteSpace()
                            }
                        
                        Picker("Working hour's", selection: $viewModel.userSettings.workingHours) {
                            ForEach(0..<9) {
                                Text("\($0)")
                            }
                        }
                        
                        Toggle("Work on weekends", isOn: $viewModel.userSettings.workOnWeekend)
                            .onChange(of: viewModel.userSettings.workOnWeekend) {
                                viewModel.workOnWeekend()
                            }
                        if viewModel.userSettings.workOnWeekend {
                            Toggle("Saturday", isOn: $viewModel.userSettings.saturday)
                            Toggle("Sunday", isOn: $viewModel.userSettings.sunday)
                            Toggle("Holiday's", isOn: $viewModel.userSettings.holidays)
                        }
                    }
                    Button("Save Settings", action: {viewModel.saveSettingsToUserDefaults()})
                }
            .alert(viewModel.alert?.title ?? "Error Occured", isPresented: Binding(value: $viewModel.alert)) {
                
            } message: {
                Text(viewModel.alert?.message ?? "")
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
