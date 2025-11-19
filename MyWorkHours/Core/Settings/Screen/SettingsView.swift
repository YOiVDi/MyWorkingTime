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
    @EnvironmentObject var purchaseViewModel: PurchaseViewModel
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
                
                // MARK: - First Work
                WorkdaySettingsView(section: "Main Work", companyName: $viewModel.firstWorkSettings.companyName, startShift: $viewModel.firstWorkSettings.startShift, endShift: $viewModel.firstWorkSettings.endShift, pause: $viewModel.firstWorkSettings.pause, workOnWeekend: $viewModel.firstWorkSettings.workOnWeekend, saturday: $viewModel.firstWorkSettings.saturday, startInSaturday: $viewModel.firstWorkSettings.startInSaturday, endInSaturday: $viewModel.firstWorkSettings.endInSaturday, pauseSaturday: $viewModel.firstWorkSettings.pauseSaturday, sunday: $viewModel.firstWorkSettings.sunday, startInSunday: $viewModel.firstWorkSettings.startInSunday, endInSunday: $viewModel.firstWorkSettings.endInSunday, pauseSunday: $viewModel.firstWorkSettings.pauseSunday)
                
                    
                    // MARK: - Second Work Toggle
                VStack {
                    HStack {
                        Text("Premium feature")
                        Image(systemName: "crown")
                            .foregroundStyle(viewModel.userStatus == .subscribed ? .blue.opacity(0.7) : .secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .font(.system(size: 20)).bold()
                .listRowBackground(Color.clear)
                
                    Toggle("Second Work", isOn: $viewModel.firstWorkSettings.secondWork)
                    .disabled(viewModel.userStatus == .basic)
                    
                    // MARK: - Second Work
                if viewModel.userStatus == .subscribed {
                    if viewModel.firstWorkSettings.secondWork != false {
                        WorkdaySettingsView(section: "Second Work", companyName: $viewModel.secondWorkSettings.companyName, startShift: $viewModel.secondWorkSettings.startShift, endShift: $viewModel.secondWorkSettings.endShift, pause: $viewModel.secondWorkSettings.pause, workOnWeekend: $viewModel.secondWorkSettings.workOnWeekend, saturday: $viewModel.secondWorkSettings.saturday, startInSaturday: $viewModel.secondWorkSettings.startInSaturday, endInSaturday: $viewModel.secondWorkSettings.endInSaturday, pauseSaturday: $viewModel.secondWorkSettings.pauseSaturday, sunday: $viewModel.secondWorkSettings.sunday, startInSunday: $viewModel.secondWorkSettings.startInSunday, endInSunday: $viewModel.secondWorkSettings.endInSunday, pauseSunday: $viewModel.secondWorkSettings.pauseSunday)
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
                        .disabled(viewModel.firstWorkSettings.companyName.count < 3)
                        Spacer()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(colorScheme == .dark ? Color(UIColor.black) : Color(UIColor.white))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showPremiumView = true
                    } label: {
                        Label("Premium", systemImage: "crown")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showPremiumView) {
                ZStack(alignment: .topTrailing) {
//                    PurchaseView(userStatusManager: viewModel.userStatusManager)
                    SubscriptionScreen(viewModel: purchaseViewModel)
                    VStack {
                        Button {
                            viewModel.showPremiumView = false
                        } label: {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 30))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding()
                }
            }
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
    let services = ServicesContainer()
    let userStatusManager = UserStatusManager(userDefaultsStore: UserDefaultsStore())
    SettingsView()
        .environmentObject(SettingsView.SettingsViewModel(services, userStatusManager))
}
