//
//  Pause+CoreDataProperties.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 03.06.24.
//
//

import Foundation
import CoreData


extension Pause {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pause> {
        return NSFetchRequest<Pause>(entityName: "Pause")
    }

    @NSManaged public var finishPause: Date?
    @NSManaged public var identifier: String?
    @NSManaged public var startPause: Date?
    @NSManaged public var timestamp: Date?
    @NSManaged public var totalPause: Int64
    @NSManaged public var workingDay: WorkingDay?
    
    public var wrappedStartPause: Date {
        startPause ?? Date.now
    }
    
    public var wrappedFinishPause: Date {
        finishPause ?? Date.now
    }
    
    public var wrappedWorkedTime: Int {
        Int(totalPause)
    }
    
    public var wrappedIdentifier: String {
        identifier ?? "\(Date())"
    }
    
}

extension Pause : Identifiable {

}
