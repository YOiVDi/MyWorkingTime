
import CoreData
import Foundation

final class WorkingDayPauseService: WorkingDayPauseProtocol {
    
    // MARK: - Properties
    private let persistenceController: PersistenceController
    private let context: NSManagedObjectContext
    private let workingDaysQueryService: WorkingDaysQueryServiceProtocol
    
    // MARK: - Initializer
    init(persistenceController: PersistenceController, workingDaysQueryServices: WorkingDaysQueryServiceProtocol) {
        self.persistenceController = persistenceController
        self.context = persistenceController.container.viewContext
        self.workingDaysQueryService = workingDaysQueryServices
    }
    
    // MARK: - Create
    func addPause(for workDay: WorkDay, beginPause: Date, endOfPause: Date) {
        guard let day = workingDaysQueryService.fetchOnId(workDay.id) else { return }
//        workDay.pause.append(WorkDayPause(id: UUID().uuidString, startPause: beginPause, finishPause: endOfPause))
        addPauseToRepository(for: day, beginPause: beginPause, endOfPause: endOfPause)
    }
    
    private func addPauseToRepository(for workDay: WorkingDay, beginPause: Date, endOfPause: Date) {
        let pause = Pause(context: context)
        pause.identifier = UUID().uuidString
        pause.startPause = beginPause
        pause.finishPause = endOfPause
        workDay.addToPauses(pause)
        persistenceController.save()
    }
    
    // MARK: - Read   
    private func fetchFromModel(for workDay: WorkingDay, pauseId: String) -> Pause? {
        guard let pause = workDay.arrPause.first(where: { $0.identifier == pauseId}) else { return nil}
        return pause
    }
    
    // MARK: - Update
    
    // Update pause is not in use
    func updatePause(for workDay: WorkDay, pause: WorkDayPause, beginPause: Date, endOfPause: Date) {
        guard let coredataObject = workingDaysQueryService.fetchOnId(workDay.id) else { return }
        guard let pauseToUpdate = fetchFromModel(for: coredataObject, pauseId: pause.id) else { return }
        updatePauseInRepository(pause: pauseToUpdate, beginPause: beginPause, endOfPause: endOfPause)
    }
    
    private func updatePauseInRepository(pause: Pause, beginPause: Date, endOfPause: Date) {
        let pause = pause
        pause.startPause = beginPause
        pause.finishPause = endOfPause
        persistenceController.save()
    }
    
    // MARK: - Delete
    func deletePause(for workDay: WorkDay ,pause: WorkDayPause) {
        guard let coredataObject = workingDaysQueryService.fetchOnId(workDay.id) else { return }
        guard let pauseToDelete = fetchFromModel(for: coredataObject, pauseId: pause.id) else {return}
        deletePauseInRepository(pause: pauseToDelete)
    }
    
    private func deletePauseInRepository(pause: Pause) {
        context.delete(pause)
        persistenceController.save()
    }
}
