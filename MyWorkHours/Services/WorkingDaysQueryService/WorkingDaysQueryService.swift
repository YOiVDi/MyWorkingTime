import CoreData
import Foundation

final class WorkingDaysQueryService: WorkingDaysQueryServiceProtocol {
    // MARK: - Properties
    private let persistenceController: PersistenceController
    private let context: NSManagedObjectContext
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        context = persistenceController.container.viewContext
    }
    
    // MARK: - Creat
    
    // Add object to the repository
    func addObjectToRepository(company: String, for date: Date, startShift: Date, endShift: Date, workingHours: Int) {
        let newDay = WorkingDay(context: persistenceController.container.viewContext)
        newDay.id = UUID()
        newDay.companyName = company
        newDay.date = date
        newDay.workingHours = Int16(workingHours)
        persistenceController.save()
    }
    
    
    // MARK: - Read
    
    // Fetches the object for the specified date from the repository.
    func fetchOnDate(on date: Date) -> [WorkingDay] {
        let start: Date = Calendar.current.startOfDay(for: date)
        let end: Date = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        
        let days: [WorkingDay]
        let request: NSFetchRequest<WorkingDay> = WorkingDay.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        
        do {
            days = try context.fetch(request)
        } catch {
            print("Day's cannot be fetched")
            return []
        }
        
        return days
    }
    
    // Fetch all object from the repository
    func fetchAllObjects(sortBy: [NSSortDescriptor]) -> [WorkingDay] {
        let workDays: [WorkingDay]
        let request: NSFetchRequest<WorkingDay> = WorkingDay.fetchRequest()
        request.sortDescriptors = sortBy
        
        do {
          workDays =  try persistenceController.container.viewContext.fetch(request)
        } catch {
            print("Error fetching \(error)")
            workDays = []
        }
        return workDays
    }
    
    // MARK: - Update
    
    func update(_ workDay: WorkDay) {
        guard let coreDataObject =  fetchOnId(workDay.id) else { return }
        coreDataObject.date = workDay.date
        coreDataObject.workingHours = Int16(workDay.workHours)
        coreDataObject.checkIn = workDay.checkIn
        coreDataObject.checkOut = workDay.checkOut
        coreDataObject.workedTime = Int64(workDay.workedTime)
        persistenceController.save()
    }
    
    // MARK:  - Delete
    
    // Delete single object from the repository
    func delete(_ workDay: WorkingDay) {
        persistenceController.container.viewContext.delete(workDay)
        persistenceController.save()
    }
    
    // MARK: - Private Methods
    
    func fetchOnId(_ id: UUID) -> WorkingDay? {
        let request: NSFetchRequest<WorkingDay> = WorkingDay.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(request).first
    }
    
}
