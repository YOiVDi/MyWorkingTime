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
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var viewModel: SettingsViewModel
    var showFinishButton: Bool? = false
    var finishAction: (() -> Void)? = nil
    private var notificationMessage: LocalizedStringResource = """
        Enable notifications to make the most of the timer.
        We’ll remind you one minute before your timer ends, even if the app is closed. This way, you won’t miss important breaks, tasks, or deadlines.
        """
    
    // MARK: Body
    var body: some View {
        NavigationView {
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
                
                Section {
                    HStack {
                        Spacer()
                        Button {
                            viewModel.requestNotificationPermission()
                        } label: {
                            Text(viewModel.btnTitle)
                                .foregroundStyle(viewModel.btnTitle == "Turn off" ? .red : .blue)
                        }
                        Spacer()
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text(notificationMessage)
                        .multilineTextAlignment(.center)
                }
                if showFinishButton == true {
                    HStack {
                        Spacer()
                        Button {
                            (finishAction ?? {})()
                        } label: {
                            Text("Finish")
                                .frame(width: 120)
                                .font(.title3.bold())
                        }
                        //                            .buttonStyle(BorderedProminentButtonStyle())
                        .disabled(viewModel.companyName.count < 3)
                        Spacer()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(colorScheme == .dark ? Color(UIColor.black) : Color(UIColor.white))
            .navigationTitle("Settings")
        }
        .onChange(of: scenePhase) {
            viewModel.checkAuthorizationStatus()
        }
    }
    
    init(showFinishButton: Bool = false, finishAction: (() -> Void)? = nil) {
        self.showFinishButton = showFinishButton
        self.finishAction = finishAction
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsView.SettingsViewModel())
}
