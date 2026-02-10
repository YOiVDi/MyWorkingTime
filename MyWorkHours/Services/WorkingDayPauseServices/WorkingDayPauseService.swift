
import CoreData
import Foundation

final class WorkingDayPauseService: WorkingDayPauseProtocol {
    
    // MARK: - Properties
    private let persistenceController: PersistenceController
    private let context: NSManagedObjectContext
    
    // MARK: - Initializer
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        self.context = persistenceController.container.viewContext
    }
    
    // MARK: - Create
    func addPause(for workDay: WorkDay, beginPause: Date, endOfPause: Date) {
        
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
//    func fetch(workDay: WorkDay) -> [WorkDayPause] {
//        
//        fetchFromModel(workDay: <#T##WorkingDay#>)
//    }
//    
    private func fetchFromModel(workDay: WorkingDay) -> [Pause] {
        return workDay.arrPause
    }
    
    // MARK: - Update
    func updatePause(pause: WorkDayPause, beginPause: Date, endOfPause: Date) {
        
    }
    private func updatePauseInRepository(pause: Pause, beginPause: Date, endOfPause: Date) {
        let pause = pause
        pause.startPause = beginPause
        pause.finishPause = endOfPause
        persistenceController.save()
    }
    
    // MARK: - Delete
    func deletePause(pause: WorkDayPause) {
        
        
    }
    
    private func deletePauseInRepository(pause: Pause) {
        context.delete(pause)
        persistenceController.save()
    }
}
