//
//  WorkingDayViewModel.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 24.01.24.
//

import CoreData
import SwiftUI


extension WorkingDaysView {
    @MainActor class ViewModel: ObservableObject {
        
        // MARK: - Public Properties
        @Published private(set) var workingDaysList: [WorkingDay] = []
        @Published var selections = Set<WorkingDay>()
        @Published var pendingSelections = Set<WorkingDay>()
        @Published var singelSelect: WorkingDay? = nil
        @Published var alert: CustomAlerts? = nil
        @Published var confirmationIsShowing = false
        @Published var notADayWithTodayDate = false
        @Published var createNewDaySheet = false
        
        @Published var id = UUID()
        @Published var companyName: String?
        @Published var date = Date()
        @Published var workingHours = 0
        @Published var workOnWeekend = false
        
        // MARK: - Private Properties
        private var userSettings: UserSettings?
        private let persistenceController = PersistenceController.shared
        
        
        // MARK: - Initialization
        init() {
            fetchWorkingDays(filter: nil, sortBy: [NSSortDescriptor(key: "date", ascending: true)])
            fetchUserSettings()
            companyName = userSettings?.companyName
        }
        
        // MARK: - Public Methods
        
        /// add a new working day
        func addWorkingDay() {
            fetchUserSettings()
            guard let userSettings else {
                alert = .userDefaultsIsEmpty
                return
            }
            createNewWorkingDay(userSettings: userSettings)
            fetchWorkingDays(filter: nil, sortBy: [NSSortDescriptor(key: "date", ascending: true)])

            persistenceController.save()
        }
        
        /// Create a day from a user-selected date
        func creatingDayOfUserChoice(_ dismiss: DismissAction) {
            notADayWithTodayDate = true
            addWorkingDay()
            dismiss()
            notADayWithTodayDate = false
        }
        
        /// Moves a working day within the array.
        func moveWorkingDay(from source: IndexSet, to destination: Int) {
            withAnimation {
                workingDaysList.move(fromOffsets: source, toOffset: destination)
            }
            persistenceController.save()
        }
        
        /// Deletes a working day at specified offsets.
        func deleteWorkingDay(at offsets: IndexSet) {
            withAnimation {
                guard let index = offsets.first else { return }
                let entity = workingDaysList[index]
                persistenceController.container.viewContext.delete(entity)
                workingDaysList.remove(atOffsets: offsets)
            }
            persistenceController.save()
        }
        
        /// Deletes a selected working day.
        func swipeDelete(day: WorkingDay) {
            withAnimation {
                guard let index = self.workingDaysList.firstIndex(where: { workingDay in
                    workingDay.wrappedDate == day.wrappedDate
                }) else {return}
                persistenceController.container.viewContext.delete(day)
                workingDaysList.remove(at: index)
            }
            persistenceController.save()
        }
        
        /// Alert cancel button
        func handleDeleteAction(_ editMode:  Binding<EditMode>?) {
               switch alert {
               case .deleteAll:
                   deleteSelectedWorkingDays(pendingSelections)
                   selections.removeAll()
                   editMode?.wrappedValue = .inactive
                   pendingSelections.removeAll()
               case .swipeDelete:
                   if let selection = singelSelect {
                       swipeDelete(day: selection)
                       singelSelect = nil
                   }
               default:
                   break
               }
               alert = nil
           }
        
        ///  Alert cancel button
         func handleCancelAction(_ editMode:  Binding<EditMode>?) {
            switch alert {
            case .deleteAll:
                withAnimation {
                    editMode?.wrappedValue = .active
                }
                selections = pendingSelections
            default:
                break
            }
            alert = nil
        }
        
        
        // MARK: - Private Methods
        
        /// Creates a new working day based on user settings.
        /// - Parameter userSettings: Predefined user settings for initializing a new working day.
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
        }
        
        /// Fetches working days with optional filtering and sorting.
        private func fetchWorkingDays(filter: NSPredicate?, sortBy: [NSSortDescriptor]?) {
            workingDaysList = persistenceController.fetchRequest(filter: filter, sortBy: sortBy)
        }
        
        /// Checks if a working day already exists for the specified date.
       private func doesDayExist() -> Bool {
            let targetDate = notADayWithTodayDate ? self.date : Date()
            
            let calendar = Calendar.current
            
            let itemExist = workingDaysList.contains { day in
                return calendar.isDate(day.wrappedDate, inSameDayAs: targetDate)
            }
            return itemExist
        }
        
        
        /// Deletes multiple selected working days.
        private func deleteSelectedWorkingDays(_ selection: Set<WorkingDay>) {
            for object in selection {
                if let index = workingDaysList.firstIndex(where: {$0 == object}) {
                    let entity = workingDaysList[index]
                    persistenceController.container.viewContext.delete(entity)
                    workingDaysList.remove(at: index)
                }
            }
            persistenceController.save()
        }
    }
}
