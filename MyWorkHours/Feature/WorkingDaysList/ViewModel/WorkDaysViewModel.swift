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
        @Published private(set) var workingDaysList: [WorkDay] = []
        @Published private(set) var todayCheckInCheckOut: WorkDay?
        
        // MARK: - Public Properties
        @Published var userDefinedWorkDay: UserDefinedWorkDay = UserDefinedWorkDay()   /// A struct which is helpe to define a custom work day
        @Published var selections: Set<WorkDay> = Set<WorkDay>()
        @Published var pendingSelections: Set<WorkDay> = Set<WorkDay>()
        @Published var singleSelect: WorkDay? = nil
        @Published var alert: CustomAlerts? = nil
        @Published var createNewDaySheet = false
        @Published var showCheckInOutCard = false { didSet {  if showCheckInOutCard { refreshToday() } } }
        @Published var workChoice: UserDefaultsKeys = .firstWorkSettings { didSet { refreshToday() } }
        @Published var sortBy: SortByWorkDay = .newestFirst
        
        //
        private var sectionArray: [SectionModel] = []
        
        // MARK: - Managers
        private let userStatusManager: UserStatusStore
        private let userSettingsStore: UserSettingsStore
        
        // MARK: - Service
        private let workingDaysService: WorkingDaysServicesProtocol
        private let workingDayPauseService: WorkingDayPauseProtocol
        private let checkInOutService: WorkDayCheckInOutProtocol
        
        
        // MARK: - Computed Properties
        
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
        var workDays: [WorkDay] {
            switch sortBy {
            case .newestFirst:
                return workingDaysList.sorted { $0.date > $1.date }

            case .oldestFirst:
                return workingDaysList.sorted { $0.date < $1.date }
            }
        }
        
        var isPremium: Bool {
            userStatusManager.userStatus == .subscribed
        }
        
        var userFirstWorkSettings: UserSettings {
            userSettingsStore.firstWorkSettings
        }
        
        var userSecondWorkSettings: UserSettings {
            userSettingsStore.secondWorkSettings
        }
        
        // MARK: - Initialization
        init(userStatusManager: UserStatusStore, servicesContainer: ServicesContainerProtocol) {
            self.userStatusManager = userStatusManager
            self.workingDaysService = servicesContainer.workDaysService
            self.workingDayPauseService = servicesContainer.workingDayPauseService
            self.checkInOutService = servicesContainer.workDayCheckInOutService
            self.userSettingsStore = servicesContainer.userSettingsStore
            fetchWorkDays()
            sectionWorkDays()
        }
        
        // MARK: - Public Methods
        
        // Make viewmodel for DetailView
        func makeDetailViewModel(for workDay: WorkDay) -> DetailScreen.ViewModel {
            return DetailScreen.ViewModel(model: workDay, workingDayPauseService: workingDayPauseService)
        }
        
        /// Create a day from a user-selected date
        func creatingDayOfUserChoice(_ dismiss: DismissAction) {
            userDefinedWorkDay.workingHours = Date().returnWorkTimeAsInt(startShift: userDefinedWorkDay.startShift, endShift: userDefinedWorkDay.endShift)
            addWorkingDay()
            dismiss()
            fetchWorkDays()
        }
        
        /// Deletes a single working day.
        func swipeDelete(day: WorkDay) {
            let index = workingDaysList.firstIndex { $0.id == day.id}
            guard let index else { return }
            workingDaysService.delete(day)
            workingDaysList.remove(at: index)
            sectionWorkDays()
        }
        
        /// Handle alerts buttons
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
            if userStatusManager.userStatus == .basic || userSettingsStore.firstWorkSettings.secondWork == false {
                return true
            } else {
                return false
            }
        }
        
        /// Handle check-in action
        func handleCheckIn() {
            guard var today = todayCheckInCheckOut else { return }
            checkInOutService.handleCheckIn(&today, workingDaysList: &workingDaysList)
            todayCheckInCheckOut = today
        }
        
        /// Handle check-out action
        func handleCheckOut() {
            guard var today = todayCheckInCheckOut else { return }
            guard today.checkIn != nil else { return }
            checkInOutService.handleCheckOut(&today, workingDaysList: &workingDaysList)
            todayCheckInCheckOut = today
            showCheckInOutCard.toggle()
        }
              
        func calculateTime(_ workDay: WorkDay) -> String {
            let pause = calculatePauseInSeconds(workDay)
            let workHoursInSecondsAndPause = (workDay.workHours * 60) - pause
            let calc = workDay.workedTime - workHoursInSecondsAndPause
            print("Pauses: \(pause)")
            print("WorkingHoursWithOutPause: \(workHoursInSecondsAndPause)")
            print("WorkedTime: \(workDay.workedTime)")
            print("Calc: \(calc)")
            return WorkTimeConverter.convertSecondToTime(calc, true)
        }
        
         func calculatePauseInSeconds(_ workDay: WorkDay) -> Int {
             let weekday = DateHelper.weekday(from: workDay.date)
             var pauseTime: Date?
             
             if DateHelper.isSunday(weekday) {
                 pauseTime = workDay.companyName == userSettingsStore.firstWorkSettings.companyName ? userSettingsStore.firstWorkSettings.pauseSunday : userSettingsStore.secondWorkSettings.pauseSunday
             } else if DateHelper.isSaturday(weekday) {
                 pauseTime = workDay.companyName == userSettingsStore.firstWorkSettings.companyName ? userSettingsStore.firstWorkSettings.pauseSaturday : userSettingsStore.secondWorkSettings.pauseSaturday
             } else {
                 pauseTime = workDay.companyName == userSettingsStore.firstWorkSettings.companyName ? userSettingsStore.firstWorkSettings.pause : userSettingsStore.secondWorkSettings.pause
             }
             
             return DateHelper.minutesToSeconds(pauseTime)
        }
        
        /// Check if a day is weekend
        /// - Returns: work hours for specific day as Int
        func checkWeekday(_ day: Date) {
            let weekday = Calendar.current.component(.weekday, from: day)
            let settings = workChoice == .firstWorkSettings ? userSettingsStore.firstWorkSettings : userSettingsStore.secondWorkSettings
            
            switch weekday {
                // Sunday
            case 1:
                userDefinedWorkDay.startShift = DateComponentsExtractor.settingTime(from: settings.startInSunday)
                userDefinedWorkDay.endShift = DateComponentsExtractor.settingTime(from: settings.endInSunday)
            case 7:
                userDefinedWorkDay.startShift = DateComponentsExtractor.settingTime(from: settings.startInSaturday)
                userDefinedWorkDay.endShift = DateComponentsExtractor.settingTime(from: settings.endInSaturday)
            default:
                userDefinedWorkDay.startShift = DateComponentsExtractor.settingTime(from: settings.startShift)
                userDefinedWorkDay.endShift = DateComponentsExtractor.settingTime(from: settings.endShift)
            }
        }
        
        // MARK: - Private Methods
        
        // Refresh today property
        private func refreshToday() {
            let settings = (workChoice == .firstWorkSettings ? userSettingsStore.firstWorkSettings : userSettingsStore.secondWorkSettings)
            todayCheckInCheckOut = checkInOutService.assingDayForCheckInCheckOut(for: workChoice, settings)
        }
        
        /// Add a new working day
        private func addWorkingDay() {
            do {
                try workingDaysService.addWorkDay(company: workChoice == .firstWorkSettings ? userSettingsStore.firstWorkSettings.companyName : userSettingsStore.secondWorkSettings.companyName , for: userDefinedWorkDay.date, startShift: userDefinedWorkDay.startShift, endShift: userDefinedWorkDay.endShift, workingHours: userDefinedWorkDay.workingHours, settings: (workChoice == .firstWorkSettings ? userSettingsStore.firstWorkSettings : userSettingsStore.secondWorkSettings))
            } catch CustomAlerts.dayExist {
                alert = .dayExist
                return
            } catch CustomAlerts.emptyCompanyName {
                alert = .userDefaultsIsEmpty
                return
            } catch {
                print("Unknown error: \(error)")
                print("UserSettings: \(userSettingsStore.firstWorkSettings.companyName)")
            }
            fetchWorkDays()
        }
        
        /// Deletes selections of mutiple working days.
        private func deleteSelectedWorkingDays(_ selection: Set<WorkDay>) {
            workingDaysService.deleteSelected(selected: selection)
            let ids = selection.map(\.id)
            workingDaysList.removeAll { ids.contains($0.id) }
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
            workingDaysList = workingDaysService.fetch()
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
            let grouped: [Date : [WorkDay]] = CollectionFilters.groupedByMonthYear(items: workingDaysList, dateKeyPath: \.date)
            let section: [SectionModel] = grouped.map { (key, value) in
                SectionModel(name: DateHelper.yearMonthFormatter(key), items: value.sorted { $0.date > $1.date }, date: key)
            }
            sectionArray = section
        }
    }
}
