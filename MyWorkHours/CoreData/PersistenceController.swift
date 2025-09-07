//
//  PersistenceController.swift
//  WorkingHours
//
//  Created by Yordan Dimitrov on 18.03.24.
//

import Foundation
import CoreData

struct PersistenceController {
    // A singleton for our entire app to use
    static let shared = PersistenceController()
    
    // Storage for Core Data
    let container: NSPersistentCloudKitContainer
    
    // A test configuration for SwiftUI previews
    static var preview: WorkingDay = {
        let controller = PersistenceController.shared.container
        let workingDay = WorkingDay(context: controller.viewContext)
        workingDay.id = UUID()
        workingDay.companyName = "NoName Company"
        workingDay.date = Date()
        workingDay.workingHours = 8
        workingDay.workOnWeekend = false
        for _ in 0..<3 {
            let pause = Pause(context: controller.viewContext)
            pause.startPause = Date(timeIntervalSinceNow: 1200)
            pause.finishPause = Date(timeIntervalSinceNow: 1800)
            pause.totalPause = 10
            workingDay.addToPauses(pause)
        }
        return workingDay
    }()
    
    // An initializer to load Core Data, optionally able
    // to use an in-memory store.
    private init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "WorkingHours")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error to load PersistenceStores: \(error)")
                return
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
            }
        }
    }
    
    func fetchRequest(/*filter: NSPredicate?,*/ sortBy: [NSSortDescriptor]?) -> [WorkingDay] {
        var workingDaysList: [WorkingDay] = []
        let request = NSFetchRequest<WorkingDay>(entityName: "WorkingDay")
//        request.predicate = filter
        request.sortDescriptors = sortBy
        do {
            workingDaysList = try container.viewContext.fetch(request)
        } catch {
            print("Error fetching \(error)")
        }
        return workingDaysList
    }
    
    /// Delete workday
    func deleteDay(_ item: WorkingDay) {
        let context = container.viewContext
        context.delete(item)
        
        do {
            try context.save()
        } catch {
            context.rollback()
            print("Failed to delete item: \(error)")
        }
        save()
    }
    
    /// Delete selected days
    func deleteSelectedWorkingDays(_ selection: Set<WorkingDay>, items: [WorkingDay]) {
         let context = container.viewContext
        for object in selection {
            if let index = items.firstIndex(where: {$0 == object}) {
                let entity = items[index]
                context.delete(entity)
            }
        }
         save()
    }
    
    /// Creates a new workday based on user settings.
    /// - Parameter userSettings: Predefined user settings for initializing a new working day.
    func addItem(userSettings: UserSettings, notADayWithTodayDate: Bool, date: Date, workingHours: Int, isWeekend: @escaping () -> Int) {
        let context = container.viewContext
        let newWorkingDay = WorkingDay(context: context)
        newWorkingDay.id = UUID()
        newWorkingDay.companyName = userSettings.companyName
        newWorkingDay.date = notADayWithTodayDate ? date : Date()
        newWorkingDay.workingHours = Int16(notADayWithTodayDate ? workingHours : isWeekend())

        save()
    }

}
