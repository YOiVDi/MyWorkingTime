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
        @Published var alert: CustomAlerts? = nil
        
        // Singleton instance of PersistenceController(Core-Data)
        private let persistenceController = PersistenceController.shared
        
        
        
        init() {
            fetchCoreData(filter: nil, sortBy: [])
        }
        
        // Check if current day exist in list.
        func dayExist() -> Bool {
            let targetDate = Date() // Use Date() to get the current date
            let calendar = Calendar.current
            
            let itemExist = workingDaysList.contains { day in
                return calendar.isDate(day.wrappedDate, inSameDayAs: targetDate)
            }
            return itemExist
        }
        
        // MARK: ListView Functions
        
        // function to add new day
        func add() {
            // Check if the day already exists
            guard !dayExist() else {
                alert  = .dayExist
                return
            }
            
            // Retrieve user settings
            guard let userData = UserDefaults.standard.data(forKey: "userSettings") else {
                print("No user settings data found.")
                return
            }
            
            do {
                let userSettings = try JSONDecoder().decode(UserSettings.self, from: userData)
                
                // Create a new WorkingDay object
                let newWorkingDay = WorkingDay(context: persistenceController.container.viewContext)
                newWorkingDay.id = UUID()
                newWorkingDay.companyName = userSettings.companyName
                newWorkingDay.date = Date.now
                newWorkingDay.workingHours = Int16(userSettings.workingHours)
                newWorkingDay.workOnWeekend = userSettings.workOnWeekend
                
                // Add the new WorkingDay object to the list
                withAnimation {
                    workingDaysList.append(newWorkingDay)
                }
                
                // Save changes
                persistenceController.save()
            } catch {
                print("Failed to decode user settings data:", error.localizedDescription)
            }
        }
        
        
        // Function to delete object.
        func delete(at offsets: IndexSet) {
            withAnimation {
                guard let index = offsets.first else { return }
                let entity = workingDaysList[index]
                persistenceController.container.viewContext.delete(entity)
                workingDaysList.remove(atOffsets: offsets)
            }
            persistenceController.save()
        }
        
        
        // Function for delete several items at once
        func selectionDelete(_ selection: Set<WorkingDay>) {
            for object in selection {
                if let index = workingDaysList.firstIndex(where: {$0 == object}) {
                    let entity = workingDaysList[index]
                    persistenceController.container.viewContext.delete(entity)
                    workingDaysList.remove(at: index)
                }
            }
            persistenceController.save()
        }
        
        // Function to move position within array (workingDays).
        func move(from source: IndexSet, to destination: Int) {
            withAnimation {
                workingDaysList.move(fromOffsets: source, toOffset: destination)
            }
            persistenceController.save()
        }
        
        func fetchCoreData(filter: NSPredicate?, sortBy: [NSSortDescriptor]?) {
            workingDaysList = persistenceController.fetchRequest(filter: filter, sortBy: sortBy)
        }
    }
}
