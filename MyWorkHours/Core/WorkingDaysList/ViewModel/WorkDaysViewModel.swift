//
//  WorkingDayViewModel.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 24.01.24.
//

import Combine
import CoreData
import CloudKit
import SwiftUI

enum SortByWorkDay: LocalizedStringKey, CaseIterable {
    case newestFirst = "Newest First"
    case oldestFirst = "Oldest First"
}

extension WorkDaysScreen {
    @MainActor class ViewModel: ObservableObject {
        // MARK: - Published Private(set) Properties
        @Published private(set) var workingDaysList: [WorkingDay] = []
        @Published private(set) var todayCheckInCheckOut: WorkingDay?
        @Published private(set) var notADayWithTodayDate = false
        
        // MARK: - Public Properties
        @Published var selections = Set<WorkingDay>()
        @Published var pendingSelections = Set<WorkingDay>()
        @Published var singleSelect: WorkingDay? = nil
        @Published var alert: CustomAlerts? = nil
        @Published var createNewDaySheet = false
        @Published var showCheckInOutCard = false
        @Published var workChoice: UserDefaultsKeys = .firstWorkSettings
        @Published var sortBy: SortByWorkDay = .newestFirst
        
        // If user status is premium
        var section: [SectionModel] {
            switch sortBy {
            case .newestFirst:
                return sectionArray.sorted { $0.date > $1.date }

            case .oldestFirst:
                return sectionArray.sorted { $0.date < $1.date }
            }
        }
        
        // If user status is basic
        var workDays: [WorkingDay] {
            switch sortBy {
            case .newestFirst:
                return workingDaysList.sorted { $0.wrappedDate > $1.wrappedDate }

            case .oldestFirst:
                return workingDaysList.sorted { $0.wrappedDate < $1.wrappedDate }
            }
        }
        
        /// A struct which is helpe to define a custom work day
        var userDefinedWorkDay: UserDefinedWorkDay = UserDefinedWorkDay()
        

        // Hold user defaults
        private(set) var userSettings: UserSettings?
        private(set) var secondUserSettings: UserSettings?
        private var sectionArray: [SectionModel] = []
        
        // MARK: - PersistenceController
        let persistenceController: PersistenceController
        let userStatusManager: UserStatusManager
        
        
        // MARK: - Computed Properties
        
        
        // MARK: - Initialization
        init(persistenceController: PersistenceController, userStatusManager: UserStatusManager) {
            self.persistenceController = persistenceController
            self.userStatusManager = userStatusManager
            fetchWorkDays()
            fetchUserSettings()
            sectionWorkDays()
        }
        
        // MARK: - Public Methods
        
        /// add a new working day
        func addWorkingDay() {
            guard !doesDayAsRequirmentsExist() else {
                alert = .dayExist
                return
            }
            guard let userSettings else {
                alert = .userDefaultsIsEmpty
                return
            }
            
            guard let secondUserSettings else {
                alert = .userDefaultsIsEmpty
                return
            }
            
            persistenceController.addWorkDay(userSettings: workChoice == .firstWorkSettings ? userSettings : secondUserSettings, notADayWithTodayDate: notADayWithTodayDate, date: userDefinedWorkDay.date, workingHours: userDefinedWorkDay.workingHours, isWeekend: isWeekend)
            fetchWorkDays()
        }
        
        /// Create a day from a user-selected date
        func creatingDayOfUserChoice(_ dismiss: DismissAction) {
            notADayWithTodayDate = true
            userDefinedWorkDay.workingHours = Date().returnWorkTimeAsInt(startShift: userDefinedWorkDay.startShift, endShift: userDefinedWorkDay.endShift)
            addWorkingDay()
            dismiss()
            notADayWithTodayDate = false
            fetchWorkDays()
        }
        
        /// Deletes a selected working day.
        func swipeDelete(day: WorkingDay) {
            withAnimation {
                persistenceController.deleteDay(day)
                fetchWorkDays()
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
//        
//        
//        /// Check if today's date exists, if it does, assign to today's variable
//        func doesTodayExist() {
//            let targetComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
//            
//            todayCheckInCheckOut = workingDaysList.first { workDay in
//                let workDayComponents = Calendar.current.dateComponents([.year, .month, .day], from: workDay.wrappedDate)
//                return workDayComponents == targetComponents
//            }
//        }
//        
         private func isExistDaysWithTodayDate() -> [WorkingDay] {
             let targetComponents = Calendar.current.dateComponents([.year, .month, .day], from: userDefinedWorkDay.date)
             print("Target Date: \(targetComponents)")
            var workDays: [WorkingDay] = []
            for day in workingDaysList {
                let workDayComponents = Calendar.current.dateComponents([.year, .month, .day], from: day.wrappedDate)
                if targetComponents == workDayComponents {
                    workDays.append(day)
                }
            }
            return workDays
        }
        
        private func doesDayAsRequirmentsExist() -> Bool {
            isExistDaysWithTodayDate().contains { day in
                (day.companyName == userSettings?.companyName && workChoice == .firstWorkSettings) ||
                (day.companyName == secondUserSettings?.companyName && workChoice == .secondWorkSettings)
            }
        }
        
        func disableWorkChoice() -> Bool {
            fetchUserSettings()
            if userStatusManager.userStatus == .basic || userSettings?.secondWork == false {
                return true
            } else {
                return false
            }
        }
        
        
        func assingDayForCheckInCheckOut() {
            if workChoice == .firstWorkSettings {
                todayCheckInCheckOut = isExistDaysWithTodayDate().first {
                    $0.companyName == userSettings?.companyName
                }
            } else if workChoice == .secondWorkSettings {
                todayCheckInCheckOut = isExistDaysWithTodayDate().first {
                    $0.companyName == secondUserSettings?.companyName
                }
            }
        }
        
        /// Handle check-in action
        func handleCheckIn() {
//            doesTodayExist()
            assingDayForCheckInCheckOut()
            guard let today = todayCheckInCheckOut else { return } // <-- In later stage error must be implemnted here.
                today.checkIn = Date() // set check-in to time right now
            persistenceController.save()
        }
        
        /// Handle check-out action
        func handleCheckOut() {
//            doesTodayExist()
            guard todayCheckInCheckOut?.checkIn != nil else { return }
            guard let today = todayCheckInCheckOut else { return } // <-- In later stage error must be implemnted here.
            today.checkOut = Date() // set check-out to time right now
            withAnimation(.easeInOut(duration: 1)){
                showCheckInOutCard.toggle()
            }
            persistenceController.save()
        }
        
        // MARK: - Private Methods
        
        /// Check if a day is weekend
        /// - Returns: work hours for specific day as Int
        private func isWeekend() -> Int {
            let calendar = Calendar.current
            let weekDay = calendar.dateComponents([.weekday], from: Date())
            
            guard let weekday = weekDay.weekday else {
                print("Could not get weekday")
                return 0
            }
            
            var workHours = 0
            
            switch weekday {
            case 1: // Sunday
                let components = calendar.dateComponents([.hour, .minute],
                                                         from: userSettings?.startInSunday ?? Date(),
                                                         to: userSettings?.endInSunday ?? Date())
                if let hours = components.hour, let minutes = components.minute {
                    workHours = max(0, hours * 60 + minutes)
                }
                
            case 7: // Saturday
                let components = calendar.dateComponents([.hour, .minute],
                                                         from: userSettings?.startInSaturday ?? Date(),
                                                         to: userSettings?.endInSaturday ?? Date())
                if let hours = components.hour, let minutes = components.minute {
                    workHours = max(0, hours * 60 + minutes)
                }
                
            default: // Weekdays
                let components = calendar.dateComponents([.hour, .minute],
                                                         from: userSettings?.startShift ?? Date(),
                                                         to: userSettings?.endShift ?? Date())
                if let hours = components.hour, let minutes = components.minute {
                    workHours = max(0, hours * 60 + minutes)
                }
            }
            
            print("isWeekend: \(workHours)")
            print("day is \(weekday)")
            return workHours
        }
        
        /// Fetches user settings from UserDefaults.
        private func fetchUserSettings() {
            guard let userSettings = UserDefaults.standard.data(forKey: UserDefaultsKeys.firstWorkSettings.rawValue) else { return }
            guard let secondUserSettings = UserDefaults.standard.data(forKey: UserDefaultsKeys.secondWorkSettings.rawValue) else { return }
            
            do {
                self.userSettings = try JSONDecoder().decode(UserSettings.self, from: userSettings)
                self.secondUserSettings = try JSONDecoder().decode(UserSettings.self, from: secondUserSettings)
            } catch {
                print("Failed to decode user settings data:", error.localizedDescription)
                return
            }
            
            print("fetch usersettings")
        }
        
        
        /// Deletes multiple selection of working days.
        private func deleteSelectedWorkingDays(_ selection: Set<WorkingDay>) {
            persistenceController.deleteSelectedWorkingDays(selection, items: workingDaysList)
            fetchWorkDays()
        }
        
        /// Alert delete action button
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
        
        ///  Alert cancel  action button
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
        
        /// Fetch workdays from CoreData.
        private func fetchWorkDays() {
            workingDaysList = persistenceController.fetchRequest(sortBy: [NSSortDescriptor(key: "date", ascending: true)])
            sectionWorkDays()
        }
        
        // Groups workingDaysList by month into sections.
        // - Key: first day of the month (Date)
        // - Value: array of WorkingDay items for that month
        // The result is transformed into SectionModel objects with:
        //   name  = month name (e.g. "September")
        //   items = sorted WorkingDay list (newest first)
        //   date  = month key (Date)
        private func sectionWorkDays() {
            var grouped: [Date : [WorkingDay]] = [:]
            let dateFormatter = DateFormatter()
            let calendar = Calendar.current
            dateFormatter.dateFormat = "MMMM yyyy"
            for item in workingDaysList {
                let components = calendar.dateComponents([.year ,.month], from: item.wrappedDate)
                let monthName = calendar.date(from: components)
                grouped[monthName ?? .now, default: []].append(item)
            }
            let section: [SectionModel] = grouped.map { (key, value) in
                SectionModel(name: dateFormatter.string(from: key), items: value.sorted { $0.wrappedDate > $1.wrappedDate }, date: key)
            }
            sectionArray = section
        }
        
        func calculateTime(_ workDay: WorkingDay) -> String {
            // Pause time into seconds
            let pauseTime = calculatePauseInSeconds(workDay)
            // WorkHours mutiply with 60 to get in seconds
            let workHours = workDay.wrappedWorkingHours * 60
            // Calculate WorkedTime and Pause together
            let workTimeAndPause = workDay.wrappedWorkedTime + pauseTime
            // substract
            let calc = workTimeAndPause - workHours
            return WorkTimeConverter.convertSecondToTime(calc, false)
        }
        
         func calculatePauseInSeconds(_ workDay: WorkingDay) -> Int {
             WorkTimeConverter.calculatePauseInSeconds(workDay)
        }
    }
}

