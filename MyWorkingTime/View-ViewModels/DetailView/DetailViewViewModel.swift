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
        
        @Published var checkIn: Date
        @Published var checkOut: Date
        
        // MARK: - Private properties
        private let defaultTime = Calendar(identifier: .gregorian).date(bySettingHour: 0, minute: 00, second: 0, of: Date()) ?? Date()
        private let persistenceController = PersistenceController.shared
        
        // MARK: - Initialization
        init(model: WorkingDay) {
            self.model = model
            self.newWorkingTime = model.wrappedWorkingHours
            self.pauseStartEdit = defaultTime
            self.pauseFinishEdit = defaultTime
            self.checkIn = model.checkIn ?? defaultTime
            self.checkOut = model.checkOut ?? defaultTime
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
        }
        
        func editButton() {
            self.onChange = true
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
            model.workingHours = Int16(newWorkingTime)
            model.checkIn = self.checkIn
            model.checkOut = self.checkOut
            if let selectedPause {
                guard pauseFinishEdit > pauseStartEdit else {
                    print("Your Start of pause is bigger than finish pause.")
                    return
                }
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
        
        
        /// Calculate time between check-in and check-out
        /// - Returns: return calculated time
        func calculatedWorkingTime() -> String {
            var time = "Check-In and Check-Out data missing."
            if let checkIn = model.checkIn, let checkOut = model.checkOut {
                // Calculate the time interval in seconds
                var timeInterval = checkOut.timeIntervalSince(checkIn)
                
                // If the time interval is negative, add 24 hours (86400 seconds)
                if timeInterval < 0 {
                    timeInterval += 24 * 60 * 60
                }
                
                // Convert the time interval to integer seconds
                let totalSeconds = Int(round(timeInterval))
                
                // Convert the total seconds to hours, minutes, and seconds
                let hours = totalSeconds / 3600
                let minutes = (totalSeconds % 3600) / 60
                let seconds = totalSeconds % 60
                
                // Add finish working time in Core-Data
                print(totalSeconds)
                
                // Format the time as a string
                time = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            }
            return time
        }
    }
}
