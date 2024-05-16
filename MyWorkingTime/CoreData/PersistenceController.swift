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
    let container: NSPersistentContainer
    
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
            workingDay.addToPause(pause)
        }
        return workingDay
    }()
    
    // An initializer to load Core Data, optionally able
    // to use an in-memory store.
    init(inMemory: Bool = false) {
        // If you didn't name your model Main you'll need
        // to change this name below.
        container = NSPersistentContainer(name: "WorkingHours")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error to load PersistenceStores: \(error)")
                return
            }
        }
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
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
    
    func fetchRequest(filter: NSPredicate?, sortBy: [NSSortDescriptor]?) -> [WorkingDay] {
        var workingDaysList: [WorkingDay] = []
        let request = NSFetchRequest<WorkingDay>(entityName: "WorkingDay")
        request.predicate = filter
        request.sortDescriptors = sortBy
        do {
            workingDaysList = try container.viewContext.fetch(request)
        } catch {
            print("Error fetching \(error)")
        }
        return workingDaysList
    }
}
