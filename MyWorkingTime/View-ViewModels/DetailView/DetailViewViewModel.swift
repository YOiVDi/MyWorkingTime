//
//  DetailViewViewModel.swift
//  MyWorkTime
//
//  Created by Yordan Dimitrov on 09.05.24.
//

import Foundation

extension DetailView {
    class ViewModel: ObservableObject {
        // MARK: - Public properties
        @Published var selectedPause: Pause?
        @Published var model: WorkingDay
        @Published private var selectedIndex: Int?
        @Published var onChange: Bool = false
        
        @Published var newWorkingTime: Int
        @Published var pauseStartEdit: Date
        @Published var pauseFinishEdit: Date
        
        // MARK: - Private properties
        private let defaultTime = Calendar(identifier: .gregorian).date(bySettingHour: 0, minute: 00, second: 0, of: Date()) ?? Date()
        private let persistenceController = PersistenceController.shared
        
        // MARK: - Initialization
        init(model: WorkingDay) {
            self.model = model
            self.pauseStartEdit = defaultTime
            self.pauseFinishEdit = defaultTime
            self.newWorkingTime = model.wrappedWorkingHours
        }
        
        
        
        // MARK: - Public Methods
        
        /// Deletes the given pause from the working day and saves the context.
        func deletePause(pause: Pause) {
                objectWillChange.send()
                persistenceController.container.viewContext.delete(pause)
                persistenceController.save()
        }
        
        /// Updates the working day and optionally the pause with the new values.
        func update() {
            objectWillChange.send()
            guard pauseFinishEdit > pauseStartEdit else {
                print("Your Start of pause is bigger than finish pause.")
                return
            }
            model.workingHours = Int16(newWorkingTime)
            if let selectedPause {
                selectedPause.startPause = pauseStartEdit
                selectedPause.finishPause = pauseFinishEdit
            }
            persistenceController.save()
        }
        
        /// Adds a new pause to the working day.
        func addPause(for day: WorkingDay) {
            objectWillChange.send()
            let newPause = Pause(context: persistenceController.container.viewContext)
            newPause.uuid = UUID()
            newPause.startPause = pauseStartEdit
            newPause.finishPause = pauseFinishEdit
            day.addToPauses(newPause)
            persistenceController.save()
        }
    }
}
