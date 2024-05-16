//
//  DetailViewViewModel.swift
//  MyWorkTime
//
//  Created by Yordan Dimitrov on 09.05.24.
//

import Foundation

extension DetailView {
    class ViewModel: ObservableObject {
        @Published var selectedPause: Pause?
        @Published var model: WorkingDay
        @Published private var selectedIndex: Int?
        @Published var onChange: Bool = false
        
        let defaultTime = Calendar(identifier: .gregorian).date(bySettingHour: 0, minute: 00, second: 0, of: Date()) ?? Date()
        
        @Published var newWorkingTime: Int = Int()
        @Published var pauseStartEdit: Date
        @Published var pauseFinishEdit: Date
        
        init(model: WorkingDay) {
            self.model = model
            self.pauseStartEdit = defaultTime
            self.pauseFinishEdit = defaultTime
        }
        
        
        let persistenceController = PersistenceController.shared
        
        
        // Delete pause.
        func deletePause(workingDay: WorkingDay, pause: Pause) {
            workingDay.removeFromPause(pause)
            persistenceController.container.viewContext.delete(pause)
            persistenceController.save()
            objectWillChange.send()
        }
        
        // Function to update selected day
        func update(_ workingDay: WorkingDay, pause: Pause?) {
            workingDay.workingHours = Int16(newWorkingTime)
            if let pause {
                pause.startPause = defaultTime
                pause.finishPause = defaultTime
            }
            persistenceController.save()
        }
        
        func addPause(for day: WorkingDay) {
            let newPause = Pause(context: persistenceController.container.viewContext)
            newPause.startPause = pauseStartEdit
            newPause.finishPause = pauseFinishEdit
            day.addToPause(newPause)
            persistenceController.save()
            objectWillChange.send()
        }
    }
}
