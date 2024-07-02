//
//  FetchedResultsControllerManager.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 30.06.24.
//

import CoreData
import Foundation
import SwiftUI

class FetchedResultsControllerManager: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    
    
    private let fetchedResultsController: NSFetchedResultsController<WorkingDay>
    private let persistenceController: PersistenceController
    
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
}
