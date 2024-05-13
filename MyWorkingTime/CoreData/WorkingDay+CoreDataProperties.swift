//
//  WorkingDay+CoreDataProperties.swift
//  MyWorkingTime
//
//  Created by Yordan Dimitrov on 13.05.24.
//
//

import Foundation
import CoreData


extension WorkingDay {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkingDay> {
        return NSFetchRequest<WorkingDay>(entityName: "WorkingDay")
    }

    @NSManaged public var companyName: String?
    @NSManaged public var date: Date?
    @NSManaged public var workingHours: Int16
    @NSManaged public var workOnWeekend: Bool
    @NSManaged public var id: UUID?
    @NSManaged public var pause: NSSet?
    
    public var wrappedCompanyname: String {
        companyName ?? ""
    }
    
    public var wrappedDate: Date {
        date ?? Date.now
    }
    
    
    public var WrappedWorkingHours: Int {
        Int(workingHours)
    }
    
    public var arrPause: [Pause] {
        let setPause = pause as? Set<Pause> ?? []
        return setPause.sorted {
            $0.startPause ?? Date() < $1.startPause ?? Date()
        }
    }



}

// MARK: Generated accessors for pause
extension WorkingDay {

    @objc(addPauseObject:)
    @NSManaged public func addToPause(_ value: Pause)

    @objc(removePauseObject:)
    @NSManaged public func removeFromPause(_ value: Pause)

    @objc(addPause:)
    @NSManaged public func addToPause(_ values: NSSet)

    @objc(removePause:)
    @NSManaged public func removeFromPause(_ values: NSSet)

}

extension WorkingDay : Identifiable {

}
