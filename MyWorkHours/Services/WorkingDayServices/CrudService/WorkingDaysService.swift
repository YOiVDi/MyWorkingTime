import CoreData
import Foundation

final class WorkingDaysService: WorkingDaysServicesProtocol {
    private let queryService: WorkingDaysQueryServiceProtocol
    private let persistenceController: PersistenceController
    init(queryService: WorkingDaysQueryServiceProtocol, persistenceController: PersistenceController) {
        self.queryService = queryService
        self.persistenceController = persistenceController
    }
    
    // MARK: - Create
    
    // Convert DTO to repository type and add
    func addWorkDay(company: String, for date: Date, startShift: Date, endShift: Date, workingHours: Int, settings: UserSettings) throws {
        guard isDayExist(with: date, companyName: company) == false else { throw CustomAlerts.dayExist }
        guard !settings.companyName.isEmpty else { throw CustomAlerts.userDefaultsIsEmpty }
        queryService.addObjectToRepository(company: company, for: date, startShift: startShift, endShift: endShift, workingHours: workingHours)
    }
    
    // MARK: - Read
    
    /// Convert coredata object into custom plain struct
    func fetch() -> [WorkDay] {
        let coreDataItems = queryService.fetchAllObjects(sortBy: [NSSortDescriptor(key: "date", ascending: true)])
        var workDays: [WorkDay] = []
        for day in coreDataItems {
            workDays.append(WorkDayMapper.mapToDto(day))
        }
        return workDays
    }
    
    // MARK: - Updated
    func update(_ workDay: WorkDay) {
        queryService.update(workDay)
    }
    
    // MARK: - Delete
    
    func delete(_ day: WorkDay) {
        let days = queryService.fetchOnDate(on: day.date)
        for object in days where object.companyName == day.companyName && object.date == day.date {
            queryService.delete(object)
        }
    }
    
    func deleteSelected(selected workDays: Set<WorkDay>) {
        for dto in workDays {
            if let obj = queryService.fetchOnId(dto.id) {
                queryService.delete(obj)
            }
        }
    }
    
    // MARK: - Checking Methods
    private func isDayExist(with date: Date, companyName: String) -> Bool {
        let context = persistenceController.container.viewContext
        let start: Date = Calendar.current.startOfDay(for: date)
        let end: Date = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        
        let request: NSFetchRequest<WorkingDay> = WorkingDay.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@ AND companyName == %@", start as NSDate, end as NSDate, companyName as NSString)
        
        return ((try? context.count(for: request)) ?? 0) > 0
    }
}
