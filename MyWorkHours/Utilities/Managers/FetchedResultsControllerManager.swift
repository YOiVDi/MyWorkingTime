//
//  FetchedResultsControllerManager.swift
//  MyWorkingTime
//
//  Created by Yordan Dimitrov on 30.06.24.
//

import CoreData
import Foundation
import SwiftUI

class FetchedResultsControllerManager: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    
    
    private let fetchedResultsController: NSFetchedResultsController<WorkingDay>
    private let persistenceController: PersistenceController /// Start From there
    
    @Published var items: [WorkingDay] = []
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        let fetchRequest: NSFetchRequest<WorkingDay> = WorkingDay.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: persistenceController.container.viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        super.init()
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            items = fetchedResultsController.fetchedObjects ?? []
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        items = fetchedResultsController.fetchedObjects ?? []
    }
    
    /// Delete workday
    func deleteDay(_ item: WorkingDay) {
        let context = fetchedResultsController.managedObjectContext
        context.delete(item)
        
        do {
            try context.save()
        } catch {
            context.rollback()
            print("Failed to delete item: \(error)")
        }
        persistenceController.save()
    }
    
     func deleteSelectedWorkingDays(_ selection: Set<WorkingDay>) {
        let context = fetchedResultsController.managedObjectContext
        for object in selection {
            if let index = items.firstIndex(where: {$0 == object}) {
                let entity = items[index]
                context.delete(entity)
                items.remove(at: index)
            }
        }
         persistenceController.save()
    }
    
    /// Creates a new workday based on user settings.
    /// - Parameter userSettings: Predefined user settings for initializing a new working day.
    func addItem(userSettings: UserSettings, notADayWithTodayDate: Bool, date: Date, workingHours: Int, isWeekend: @escaping () -> Int) {
//        guard !doesDayExist() else {
//            alert = .dayExist
//            return
//        }
        let context = fetchedResultsController.managedObjectContext
        let newWorkingDay = WorkingDay(context: context)
        newWorkingDay.id = UUID()
        newWorkingDay.companyName = userSettings.companyName
        newWorkingDay.date = notADayWithTodayDate ? date : Date()
        newWorkingDay.workingHours = Int16(notADayWithTodayDate ? workingHours : isWeekend())
        
        // Add the new WorkingDay object to the list
        withAnimation {
            items.append(newWorkingDay)
        }
        persistenceController.save()
    }
    
    /// Checks if a working day already exists for the specified date.
    private func doesDayExist(notADayWithTodayDate: Bool, date: Date) -> Bool {
        let targetDate = notADayWithTodayDate ? date : Date()
        
        let calendar = Calendar.current
        
        let itemExist = items.contains { day in
            return calendar.isDate(day.wrappedDate, inSameDayAs: targetDate)
        }
        return itemExist
    }
}
