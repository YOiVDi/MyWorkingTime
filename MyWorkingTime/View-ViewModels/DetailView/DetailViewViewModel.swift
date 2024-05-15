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
        @Published private var selectedIndex: Int?
        @Published var onChange: Bool = false
        
        @Published var newWorkingTime: Int = Int()
        @Published var pauseStartEdit: Date = Date()
        @Published var pauseFinishEdit: Date = Date()
        
        let persistenceController = PersistenceController.shared
        
        
        // Delete pause.
        func deletePause(workingDay: WorkingDay, pause: Pause) {
            workingDay.removeFromPause(pause)
            persistenceController.container.viewContext.delete(pause)
            persistenceController.save()
        }
        
        // Function to update selected day
        func update(_ workingDay: WorkingDay, pause: Pause?) {
            workingDay.workingHours = Int16(newWorkingTime)
            if let pause {
                pause.startPause = pauseStartEdit
                pause.finishPause = pauseFinishEdit
            }
            persistenceController.save()
        }
    }
}
