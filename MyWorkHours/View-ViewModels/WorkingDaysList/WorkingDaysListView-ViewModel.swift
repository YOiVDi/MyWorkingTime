//
//  WorkingDayViewModel.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 24.01.24.
//

import CoreData
import CloudKit
import SwiftUI


extension WorkingDaysView {
    @MainActor class ViewModel: ObservableObject {
        
        // MARK: - Public Properties
        @Published var selections = Set<WorkingDay>()
        @Published var pendingSelections = Set<WorkingDay>()
        @Published var singleSelect: WorkingDay? = nil
        @Published var alert: CustomAlerts? = nil
        @Published var confirmationIsShowing = false
        @Published var createNewDaySheet = false
        @Published var showCheckInOutCard = false
        
        /// Making custom day
        @Published var id = UUID()
        @Published var companyName: String?
        @Published var date = Date()
        @Published var workingHours = 0
        @Published var workOnWeekend = false
        
        
        // MARK: - Private Properties
        @Published private(set) var workingDaysList: [WorkingDay] = []
        @Published private(set) var todayCheckInCheckOut: WorkingDay?
        @Published private(set) var notADayWithTodayDate = false
        
        
        private(set) var userSettings: UserSettings?
        private let fetchedResultsControllerManager: FetchedResultsControllerManager
        
         // MARK: - Container
        let persistenceController: PersistenceController
        
        // MARK: - Computed Properties
        
        
        // MARK: - Initialization
        init(persistenceController: PersistenceController) {
            self.persistenceController = persistenceController
            fetchedResultsControllerManager = FetchedResultsControllerManager(persistenceController: persistenceController)
            workingDaysList = fetchedResultsControllerManager.items
            fetchUserSettings()
            fetchedResultsControllerManager.$items
                .receive(on: RunLoop.main)
                .assign(to: &$workingDaysList)
            //            registerCloudKitSubscription()
        }
        
        // MARK: - Public Methods
        
        /// add a new working day
        func addWorkingDay() {
            guard !doesDayExist() else {
                alert = .dayExist
                return
            }
            fetchUserSettings()
            guard let userSettings else {
                alert = .userDefaultsIsEmpty
                return
            }
            persistenceController.addItem(userSettings: userSettings, notADayWithTodayDate: notADayWithTodayDate, date: date, workingHours: workingHours, isWeekend: isWeekend)
        }
        
        /// Create a day from a user-selected date
        func creatingDayOfUserChoice(_ dismiss: DismissAction) {
            notADayWithTodayDate = true
            addWorkingDay()
            dismiss()
            notADayWithTodayDate = false
        }
        
        /// Deletes a selected working day.
        func swipeDelete(day: WorkingDay) {
            withAnimation {
                persistenceController.deleteDay(day)
            }
            
        }
            
            /// Handle alerts buttons
            func alertButtons(_ editMode:  Binding<EditMode>?) -> some View {
                return  Group {
                    if alert == .deleteAll || alert == .swipeDelete {
                        Button("Delete", role: .destructive) {
                            self.handleDeleteAction(editMode)
                        }
                        Button("Cancel", role: .cancel) {
                            self.handleCancelAction(editMode)
                        }
                    } else {
                        Button("OK") {}
                    }
                }
            }
            
            
            /// Check if today's date exists, if it does, assign to today's variable
            func doesTodayExist() {
                let targetComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                
                todayCheckInCheckOut = workingDaysList.first(where: { workingDay in
                    let workingDayComponents = Calendar.current.dateComponents([.year, .month, .day], from: workingDay.wrappedDate)
                    return workingDayComponents == targetComponents
                })
            }
            
            /// Handle check-in action
            func handleCheckIn() {
                doesTodayExist()
                guard let today = todayCheckInCheckOut else {
                    // Handle Error Here
                    return
                }
                today.checkIn = Date() // set check-in to time right now
//                fetchedResultsControllerManager.save() // Save the updated check-in time
                withAnimation(.easeInOut(duration: 1)){
                    showCheckInOutCard.toggle()
                }
                persistenceController.save()
            }
            /// Handle check-out action
            func handleCheckOut() {
                doesTodayExist()
                guard todayCheckInCheckOut?.checkIn != nil else { return }
                guard let today = todayCheckInCheckOut else {
                    // Handle Error Here
                    return
                }
                today.checkOut = Date() // set check-out to time right now
//                fetchedResultsControllerManager.save() // Save the updated check-out time
                withAnimation(.easeInOut(duration: 1)){
                    showCheckInOutCard.toggle()
                }
                persistenceController.save()
            }
            
            func checkUserDefaults() {
                fetchUserSettings()
                self.companyName = userSettings?.companyName
                self.workingHours = userSettings?.workingHours ?? 0
                print("set initial")
            }
            
            // MARK: - Private Methods
        
        /// Checks if a working day already exists for the specified date.
        private func doesDayExist() -> Bool {
            let targetDate = notADayWithTodayDate ? date : Date()
            
            let calendar = Calendar.current
            
            let itemExist = workingDaysList.contains { day in
                return calendar.isDate(day.wrappedDate, inSameDayAs: targetDate)
            }
            return itemExist
        }
            
            /// Check if a day is weekend
            /// - Returns: work hours for specific day as Int
            private func isWeekend() -> Int {
                let deconstructDate = Calendar.current
                let weekDay = deconstructDate.dateComponents([.weekday], from: Date())
                switch weekDay.weekday {
                case 1:
                    return userSettings?.sundayHours ?? 0
                case 7:
                    return userSettings?.saturdayHours ?? 0
                default:
                    return userSettings?.workingHours ?? 0
                }
            }
            
            /// Fetches user settings from UserDefaults.
            private func fetchUserSettings() {
                guard let userData = UserDefaults.standard.data(forKey: "userSettings") else {
                    // THERE ERROR MUST BE HANDLE !!!
                    return
                }
                
                do {
                    self.userSettings = try JSONDecoder().decode(UserSettings.self, from: userData)
                } catch {
                    print("Failed to decode user settings data:", error.localizedDescription)
                    return
                }
                
                print("fetch usersettings")
            }
            
            
            /// Deletes multiple selection of working days.
            private func deleteSelectedWorkingDays(_ selection: Set<WorkingDay>) {
                persistenceController.deleteSelectedWorkingDays(selection, items: workingDaysList)
            }
            
            /// Alert cancel button
            private func handleDeleteAction(_ editMode:  Binding<EditMode>?) {
                switch alert {
                case .deleteAll:
                    deleteSelectedWorkingDays(pendingSelections)
                    selections.removeAll()
                    editMode?.wrappedValue = .inactive
                    pendingSelections.removeAll()
                case .swipeDelete:
                    if let selection = singleSelect {
                        swipeDelete(day: selection)
                        singleSelect = nil
                    }
                default:
                    break
                }
                alert = nil
            }
            
            ///  Alert cancel button
            private func handleCancelAction(_ editMode:  Binding<EditMode>?) {
                switch alert {
                case .deleteAll:
                    withAnimation {
                        editMode?.wrappedValue = .active
                    }
                    selections = pendingSelections
                case .swipeDelete:
                    singleSelect = nil
                default:
                    break
                }
                alert = nil
            }
            
            //        private func registerCloudKitSubscription() {
            //            let predicate = NSPredicate(value: true)
            //            let subscription = CKQuerySubscription(
            //                recordType: "WorkingDay",
            //                predicate: predicate,
            //                subscriptionID: "workingday_add_remove_edit",
            //                options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate]
            //            )
            //
            //            let notificationInfo = CKSubscription.NotificationInfo()
            //            notificationInfo.shouldSendContentAvailable = true // Silent notification
            //            notificationInfo.soundName = "default"
            //
            //            subscription.notificationInfo = notificationInfo
            //
            //            CKContainer.default().publicCloudDatabase.save(subscription) { subscription, error in
            //                if let error = error {
            //                    print("Failed to subscribe to CloudKit changes: \(error)")
            //                } else {
            //                    print("Successfully subscribed to CloudKit changes.")
            //                }
            //            }
//                    }
            
    }
}
