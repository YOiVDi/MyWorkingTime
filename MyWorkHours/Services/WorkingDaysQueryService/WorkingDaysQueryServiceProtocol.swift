import Foundation

protocol WorkingDaysQueryServiceProtocol {
    func fetchOnDate(on date: Date) -> [WorkingDay]
    func addObjectToRepository(company: String, for date: Date, startShift: Date, endShift: Date, workingHours: Int)
    func fetchAllObjects(sortBy: [NSSortDescriptor]) -> [WorkingDay]
    func update(_ workDay: WorkDay)
    func delete(_ workDay: WorkingDay)
    func fetchOnId(_ id: UUID) -> WorkingDay?
}
