import Foundation

protocol WorkingDaysServicesProtocol {
    func addWorkDay(company: String, for date: Date, startShift: Date, endShift: Date, workingHours: Int, settings: UserSettings) throws
    func fetch() -> [WorkDay]
    func update(_ workDay: WorkDay)
    func delete(_ day: WorkDay)
    func deleteSelected(selected workDays: Set<WorkDay>)
    func refreshWorkDay(for id: UUID) -> WorkDay?
}
