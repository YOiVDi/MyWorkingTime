//
//  WorkingDay+CoreDataProperties.swift
//  MyWorkingTime
//
//  Created by Yordan Dimitrov on 22.05.24.
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
    @NSManaged public var id: UUID?
    @NSManaged public var workingHours: Int16
    @NSManaged public var workOnWeekend: Bool
    @NSManaged public var checkIn: Date?
    @NSManaged public var checkOut: Date?
    @NSManaged public var pauses: NSSet?

}

// MARK: Generated accessors for pauses
extension WorkingDay {

    @objc(addPausesObject:)
    @NSManaged public func addToPauses(_ value: Pause)

    @objc(removePausesObject:)
    @NSManaged public func removeFromPauses(_ value: Pause)

    @objc(addPauses:)
    @NSManaged public func addToPauses(_ values: NSSet)

    @objc(removePauses:)
    @NSManaged public func removeFromPauses(_ values: NSSet)

}

extension WorkingDay : Identifiable {

}
