import Foundation

protocol WorkingDayPauseProtocol {
    func addPause(for workDay: WorkDay, beginPause: Date, endOfPause: Date)
//    func fetch(workDay: WorkDay) -> [WorkDayPause]
    func updatePause(for workDay: WorkDay, pause: WorkDayPause, beginPause: Date, endOfPause: Date)
    func deletePause(for workDay: WorkDay, pause: WorkDayPause)
}
