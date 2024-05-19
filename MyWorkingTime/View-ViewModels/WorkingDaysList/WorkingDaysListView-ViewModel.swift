//
//  WorkingDayViewModel.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 24.01.24.
//

import CoreData
import SwiftUI


extension WorkingDaysView {
    class ViewModel: ObservableObject {
        @Published private(set) var workingDaysList: [WorkingDay] = [] 
        @Published var selections = Set<WorkingDay>()
        @Published var pendingSelections = Set<WorkingDay>()
        @Published var alert: CustomAlerts? = nil
        @Published var confirmationIsShowing = false
        @Published var notADayWithTodayDate = false
        @Published var createNewDaySheet = false
        
        /// properties to create new 
        @Published var id = UUID()
        @Published var companyName: String?
        @Published var date = Date()
        @Published var workingHours = 0
        @Published var workOnWeekend = false
        
        /// Singleton instance of PersistenceController(Core-Data)
        private let persistenceController = PersistenceController.shared
        private var userSettings: UserSettings?
        
        
        
        init() {
            fetchWorkingDays(filter: nil, sortBy: [NSSortDescriptor(key: "date", ascending: true)])
            userSettings = fetchUserSettings()
            companyName = userSettings?.companyName
        }
        
        // MARK: ListView Functions
        
        /// Check if current day exist in list.
        func doesDayExist() -> Bool {
            let targetDate = notADayWithTodayDate ? self.date : Date()
            
            let calendar = Calendar.current
            
            let itemExist = workingDaysList.contains { day in
                return calendar.isDate(day.wrappedDate, inSameDayAs: targetDate)
            }
            return itemExist
        }
        
        /// function to add new day
        func addWorkingDay() {
            guard let userSettings else {
                print("No user settings data found.")
                return
            }
            
            createNewWorkingDay(userSettings: userSettings)
            fetchWorkingDays(filter: nil, sortBy: [NSSortDescriptor(key: "date", ascending: true)])

            persistenceController.save()
        }
        
        /// Create new working day
        /// - Parameter userSettings: initialize a new day based on predefined settings
        private func createNewWorkingDay(userSettings: UserSettings) {
                guard !doesDayExist() else {
                    alert = .dayExist
                    return
                }
            
            let newWorkingDay = WorkingDay(context: persistenceController.container.viewContext)
            newWorkingDay.id = UUID()
            newWorkingDay.companyName = userSettings.companyName
            newWorkingDay.date = notADayWithTodayDate ? date : Date()
            newWorkingDay.workingHours = Int16(notADayWithTodayDate ? workingHours : userSettings.workingHours)
            newWorkingDay.workOnWeekend = notADayWithTodayDate ? workOnWeekend : userSettings.workOnWeekend
            
            // Add the new WorkingDay object to the list
            withAnimation {
                workingDaysList.append(newWorkingDay)
            }
        }
        
        
        /// Checks for user default settings with a specified "Key" and if any settings exist, decodes them
        private func fetchUserSettings() -> UserSettings? {
            guard let userData = UserDefaults.standard.data(forKey: "userSettings") else {
                // THERE ERROR MUST BE HANDLE !!!
                return nil
            }
            
            do {
                return try JSONDecoder().decode(UserSettings.self, from: userData)
            } catch {
                print("Failed to decode user settings data:", error.localizedDescription)
                return nil
            }
        }
        
        /// Function to delete object.
        func deleteWorkingDay(at offsets: IndexSet) {
            withAnimation {
                guard let index = offsets.first else { return }
                let entity = workingDaysList[index]
                persistenceController.container.viewContext.delete(entity)
                workingDaysList.remove(atOffsets: offsets)
            }
            persistenceController.save()
        }
        
        
        /// Function for delete several items at once
        func deleteSelectedWorkingDays(_ selection: Set<WorkingDay>) {
            for object in selection {
                if let index = workingDaysList.firstIndex(where: {$0 == object}) {
                    let entity = workingDaysList[index]
                    persistenceController.container.viewContext.delete(entity)
                    workingDaysList.remove(at: index)
                }
            }
            persistenceController.save()
        }
        
        /// Function to move position within array (workingDays).
        func moveWorkingDay(from source: IndexSet, to destination: Int) {
            withAnimation {
                workingDaysList.move(fromOffsets: source, toOffset: destination)
            }
            persistenceController.save()
        }
        
        private func fetchWorkingDays(filter: NSPredicate?, sortBy: [NSSortDescriptor]?) {
            workingDaysList = persistenceController.fetchRequest(filter: filter, sortBy: sortBy)
        }
    }
}
