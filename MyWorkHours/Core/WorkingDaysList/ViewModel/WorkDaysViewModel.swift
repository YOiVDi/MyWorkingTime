//
//  WorkingDayViewModel.swift
//  MyWorkHours
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
        
        // MARK: - Public Properties
        @Published var userDefinedWorkDay: UserDefinedWorkDay = UserDefinedWorkDay()   /// A struct which is helpe to define a custom work day
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
        

        // Hold user Defaults and Settings
        private(set) var userSettings: UserSettings?
        private(set) var secondUserSettings: UserSettings?
        private var sectionArray: [SectionModel] = []
        
        // MARK: - PersistenceController
        let persistenceController: PersistenceController
        
        // MARK: - Managers
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
            
            persistenceController.addWorkDay(userSettings: workChoice == .firstWorkSettings ? userSettings : secondUserSettings, date: userDefinedWorkDay.date, workingHours: userDefinedWorkDay.workingHours)
            fetchWorkDays()
        }
        
        /// Create a day from a user-selected date
        func creatingDayOfUserChoice(_ dismiss: DismissAction) {
//            notADayWithTodayDate = true
            userDefinedWorkDay.workingHours = Date().returnWorkTimeAsInt(startShift: userDefinedWorkDay.startShift, endShift: userDefinedWorkDay.endShift)
            addWorkingDay()
            dismiss()
//            notADayWithTodayDate = false
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
//        func alertButtons(_ editMode:  Binding<EditMode>?) -> some View {
//            return  Group {
//                if alert == .deleteAll || alert == .swipeDelete {
//                    Button("Delete", role: .destructive) {
//                        self.handleDeleteAction(editMode)
//                    }
//                    Button("Cancel", role: .cancel) {
//                        self.handleCancelAction(editMode)
//                    }
//                } else {
//                    Button("OK") {}
//                }
//            }
//        }
        
        func alertButtons(_ editMode:  Binding<EditMode>?) -> [(title: String, role: ButtonRole? ,action: () -> Void)] {
            
            if alert == .deleteAll || alert == .swipeDelete {
                return [("Delete", .destructive ,{ self.handleDeleteAction(editMode) }),
                        ("Cancel", .cancel ,{ self.handleCancelAction(editMode)})
                ]
            } else {
                return [("OK", .none ,{})]
            }
        }

        
        func disableWorkChoice() -> Bool {
//            fetchUserSettings()
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
        
        func calculateTime(_ workDay: WorkingDay) -> String {
            let pause = calculatePauseInSeconds(workDay)
            let workHoursInSecondsAndPause = (workDay.wrappedWorkingHours * 60) - pause
            let calc = workDay.wrappedWorkedTime - workHoursInSecondsAndPause
            print("Pauses: \(pause)")
            print("WorkingHoursWithOutPause: \(workHoursInSecondsAndPause)")
            print("WorkedTime: \(workDay.wrappedWorkedTime)")
            print("Calc: \(calc)")
            return WorkTimeConverter.convertSecondToTime(calc, true)
        }
        
         func calculatePauseInSeconds(_ workDay: WorkingDay) -> Int {
             let weekday = DateHelper.weekday(from: workDay.wrappedDate)
             var pauseTime: Date?
             
             if DateHelper.isSunday(weekday) {
                 pauseTime = workDay.wrappedCompanyname == userSettings?.companyName ? userSettings?.pauseSunday : secondUserSettings?.pauseSunday
             } else if DateHelper.isSaturday(weekday) {
                 pauseTime = workDay.wrappedCompanyname == userSettings?.companyName ? userSettings?.pauseSaturday : secondUserSettings?.pauseSaturday
             } else {
                 pauseTime = workDay.wrappedCompanyname == userSettings?.companyName ? userSettings?.pause : secondUserSettings?.pause
             }
             
             return DateHelper.minutesToSeconds(pauseTime)
        }
        
        /// Check if a day is weekend
        /// - Returns: work hours for specific day as Int
        func checkWeekday(_ day: Date) {
            let weekday = Calendar.current.component(.weekday, from: day)
            let settings = workChoice == .firstWorkSettings ? userSettings : secondUserSettings
            
            switch weekday {
                // Sunday
            case 1:
                userDefinedWorkDay.startShift = DateComponentsExtractor.settingTime(from: settings?.startInSunday ?? Date())
                userDefinedWorkDay.endShift = DateComponentsExtractor.settingTime(from: settings?.endInSunday ?? Date())
            case 7:
                userDefinedWorkDay.startShift = DateComponentsExtractor.settingTime(from: settings?.startInSaturday ?? Date())
                userDefinedWorkDay.endShift = DateComponentsExtractor.settingTime(from: settings?.endInSaturday ?? Date())
            default:
                userDefinedWorkDay.startShift = DateComponentsExtractor.settingTime(from: settings?.startShift ?? Date())
                userDefinedWorkDay.endShift = DateComponentsExtractor.settingTime(from: settings?.endShift ?? Date())
            }
        }
        
        // MARK: - Private Methods
        
        
        private func isExistDaysWithTodayDate() -> [WorkingDay] {
            CollectionFilters.filterByDate(_items: workingDaysList, targetDate: userDefinedWorkDay.date, dateKeyPath: \.wrappedDate)
       }
       
        // Returns true if there's a day entry for today that matches the selected work settings.
        private func doesDayAsRequirmentsExist() -> Bool {
           isExistDaysWithTodayDate().contains { day in
               (day.companyName == userSettings?.companyName && workChoice == .firstWorkSettings) ||
               (day.companyName == secondUserSettings?.companyName && workChoice == .secondWorkSettings)
           }
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
            let grouped: [Date : [WorkingDay]] = CollectionFilters.groupedByMonthYear(items: workingDaysList, dateKeyPath: \.wrappedDate)
            let section: [SectionModel] = grouped.map { (key, value) in
                SectionModel(name: DateHelper.yearMonthFormatter(key), items: value.sorted { $0.wrappedDate > $1.wrappedDate }, date: key)
            }
            sectionArray = section
        }
    }
}
