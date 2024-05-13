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
                    TextField("Company Name", text: $viewModel.userSettings.companyName)
                        .autocorrectionDisabled()
                        .onChange(of: viewModel.userSettings.companyName) {
                            viewModel.trimWhiteSpace()
                        }
//                    DatePicker("Working Hour's", selection: $viewModel.userSettings.workingHours, displayedComponents: .hourAndMinute)
                    Picker("Working Hour's", selection: $viewModel.userSettings.workingHours) {
                        ForEach(0..<9) {
                            Text("\($0)")
                        }
                    }
                }
                Button("Save Settings", action: {viewModel.saveSettingsToUserDefaults()})
            }
            .alert(viewModel.alert?.title ?? "Error Occured", isPresented: Binding(value: $viewModel.alert)) {
                
            } message: {
                Text(viewModel.alert?.message ?? "")
            }
            .scrollContentBackground(.hidden)
            .background(Color.backGround)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
}
