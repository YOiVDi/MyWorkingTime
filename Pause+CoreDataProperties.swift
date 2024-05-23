//
//  Pause+CoreDataProperties.swift
//  MyWorkingTime
//
//  Created by Yordan Dimitrov on 22.05.24.
//
//

import Foundation
import CoreData


extension Pause {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pause> {
        return NSFetchRequest<Pause>(entityName: "Pause")
    }

    @NSManaged public var finishPause: Date?
    @NSManaged public var startPause: Date?
    @NSManaged public var totalPause: Int16
    @NSManaged public var workingDay: WorkingDay?

}

extension Pause : Identifiable {

}
