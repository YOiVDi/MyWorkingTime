//
//  DetailViewViewModel.swift
//  MyWorkTime
//
//  Created by Yordan Dimitrov on 09.05.24.
//

import SwiftUI

extension DetailView {
    class ViewModel: ObservableObject {
        // MARK: - Public properties
        @Published var selectedPause: Pause?
        @Published var model: WorkingDay
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
            self.newWorkingTime = model.wrappedWorkingHours
            self.pauseStartEdit = defaultTime
            self.pauseFinishEdit = defaultTime
        }
        
        
        
        // MARK: - Public Methods
        
        func buttons() -> some View {
            return Group {
                if (selectedPause != nil) {
                    Button(role: .destructive) {
                        self.deletePause()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } else {
                    Button {
                        self.addPause(for: self.model)
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                }
            }
            .tint(selectedPause != nil ? .red : .blue)
        }
        
        /// Deletes the given pause from the working day and saves the context.
        func deletePause() {
            guard let selectedPause else { return }
                objectWillChange.send()
                persistenceController.container.viewContext.delete(selectedPause)
                self.selectedPause = nil
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
        
        func selectPause(_ pause: Pause) {
            if selectedPause?.id == pause.id {
                selectedPause = nil
            } else {
                selectedPause = pause
                pauseStartEdit = pause.wrappedStartPause
                pauseFinishEdit = pause.wrappedFinishPause
            }
        }
    }
}
