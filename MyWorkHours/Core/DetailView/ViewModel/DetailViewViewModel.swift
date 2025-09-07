//
//  DetailViewViewModel.swift
//  MyWorkTime
//
//  Created by Yordan Dimitrov on 09.05.24.
//

import Combine
import SwiftUI
import CoreData

extension DetailView {
    class ViewModel: ObservableObject {
        // MARK: - Public properties
        @Published var selectedPause: Pause?
        @Published var model: WorkingDay
        @Published var modelPauses: [Pause]
        @Published var onChange: Bool = false
        
        @Published var newWorkingTime: Int
        @Published var pauseStartEdit: Date {
            didSet {
                isChanged()
                editSelectedPause()
            }
        }
        @Published var pauseFinishEdit: Date
        
        @Published var checkIn: Date
        @Published var checkOut: Date
        
        
        // MARK: - Private properties
        private let defaultTime = Calendar(identifier: .gregorian).date(bySettingHour: 0, minute: 00, second: 0, of: Date()) ?? Date()
        private let persistenceController: PersistenceController
        private var time = "Check-In and Check-Out data missing."
        /// Combine cancellables
        private var cancellables = Set<AnyCancellable>()
        
        // MARK: - Computed properties
        
        /// disable add pause button.
        var disableAddPause: Bool {
            return selectedPause == nil &&  model.arrPause.count == 4
        }
        
        /// show complete worked time for a day.
        var workedTime: String {
            model.workedTime != 0 ? convertTimeToSeconds(model.wrappedWorkedTime) : time
        }
        
        
        // MARK: - Initialization
        init(model: WorkingDay, modelPauses: [Pause], persistenceController: PersistenceController) {
            /// init persistenceController
            self.persistenceController = persistenceController
            /// init properties
            self.model = model
            self.modelPauses = modelPauses
            self.newWorkingTime = model.wrappedWorkingHours
            self.pauseStartEdit = defaultTime
            self.pauseFinishEdit = defaultTime
            self.checkIn = model.checkIn ?? defaultTime
            self.checkOut = model.checkOut ?? defaultTime
            testFuncPrint() // test purpose
            //                self.debouncing()
        }
        
        
        
        // MARK: - Public Methods
        
        /// Return button base of condition.
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
        
        /// Edit button
        func editButton() {
            
            // Set on change to true
            self.onChange = true
        }
        
        /// Deletes the given pause from the working day and saves the context.
        func deletePause() {
            guard let selectedPause else { return }
            
            // Delete selected pause from Core Data context
            persistenceController.container.viewContext.delete(selectedPause)
            
            // Set selectedpause to nil
            self.selectedPause = nil
            
            // Save the changes to the persistence controller
            persistenceController.save()
        }
        
        
        /// Updates the working day and optionally the pause with the new values.
        func update() {
            // Update the model's working hours, check-in, and check-out times
            model.workingHours = Int16(newWorkingTime)
            model.checkIn = self.checkIn == defaultTime ? nil : self.checkIn
            model.checkOut = self.checkOut == defaultTime ? nil : self.checkOut
            
            // Reset the selected pause to nil
            selectedPause = nil
            
            // Recalculate the working time (assuming this function exists and performs some calculation)
            calculatedWorkingTime()
            
            // Save the changes to the persistence controller
            persistenceController.save()
        }
        
        /// Debouncing data, so after typing or changing data will be saved once after 2 seconds
        private func debouncing() {
            Publishers.CombineLatest3(
                $newWorkingTime,
                $pauseStartEdit,
                $pauseFinishEdit
            )
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _, _ in
                self?.update()
            }
            .store(in: &cancellables)
            
            Publishers.CombineLatest(
                $checkIn,
                $checkOut
            )
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.update()
            }
            .store(in: &cancellables)
        }
        
        /// Adds a new pause to the working day.
        func addPause(for day: WorkingDay) {
            
            // Initialize pauseStartEdit to the current date and time
            let addStartPause = Date.now
            // Initialize pauseStartEdit to the current date and time + 15 min
            let addFinishPause = Date(timeInterval: 900, since: addStartPause)
            
            // Create a new Pause entity in the Core Data context
            let newPause = Pause(context: persistenceController.container.viewContext)
            
            // Assign a unique identifier to the newPause based on the current time, formatted as a string
            newPause.identifier = String(Date().formatted(date: .omitted, time: .standard))
            
            // Set the start time of the pause period for the newPause entity
            newPause.startPause = addStartPause
            
            // Set the finish time of the pause period for the newPause entity
            newPause.finishPause = addFinishPause
            
            // Add a pause to a  day
            day.addToPauses(newPause)
            
            // Select currently created pause
            //            selectedPause = newPause
            
            objectWillChange.send()
            
            // Save the changes to the persistence controller
            persistenceController.save()
        }
        
        /// Mark pause and show time picker's.
        func selectPause(_ pause: Pause) {
            if selectedPause?.id == pause.id {
                selectedPause = nil
                print("selectPausePrint: here")
            } else {
                selectedPause = pause
                pauseStartEdit = pause.wrappedStartPause
                pauseFinishEdit = pause.wrappedFinishPause
            }
        }
        
        
        /// Calculate time between check-in and check-out.
        /// - Returns: return calculated time.
        func calculatedWorkingTime() {
            //            var time = "Check-In and Check-Out data missing."
            if let checkIn = model.checkIn, let checkOut = model.checkOut {
                // Calculate the time interval in seconds
                var timeInterval = checkOut.timeIntervalSince(checkIn)
                
                // Calculate the time interval in seconds
                let pauseInterval = calculatePauseInSeconds()
                
                // If the time interval is negative, add 24 hours (86400 seconds).
                if timeInterval < 0 {
                    timeInterval += 24 * 60 * 60
                }
                
                // Convert the time interval to integer seconds.
                let totalSeconds = Int(round(timeInterval)) - pauseInterval
                
                // If model worked time doesn't equal to totalSeconds, then re-calculate.
                if model.wrappedWorkedTime != totalSeconds{
                    model.workedTime = Int64(totalSeconds)
                    persistenceController.save()
                }
                
                // Calculate and format the time as a string.
                self.time = convertTimeToSeconds(totalSeconds)
            }
        }
        
        
        // MARK: - Private Methods
        
        /// Converts a total number of seconds into a formatted time string (HH:mm:ss).
        /// - Parameter totalSeconds: The total number of seconds as an Int.
        /// - Returns: A formatted time string in the format "HH:mm:ss".
        private func convertTimeToSeconds(_ seconds: Int) -> String {
            
            // Convert the total seconds to hours, minutes, and seconds
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            let seconds = seconds % 60
            
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        
        /// Calculates the total duration of pauses in seconds.
        /// - Returns: The total pause time in seconds.
        private func calculatePauseInSeconds() -> Int {
            var pauseInterval = 0 // Initialize a variable to accumulate the total pause duration
            
            // Check if there are any pauses recorded in the model's array of pauses
            if model.arrPause.count != 0 {
                
                // Iterate over each pause in the array
                for pause in model.arrPause {
                    
                    // Calculate the duration of the current pause
                    let pauseTime = pause.wrappedFinishPause.timeIntervalSince(pause.wrappedStartPause)
                    
                    // Add the rounded duration of the current pause to the total pause interval
                    pauseInterval += Int(round(pauseTime))
                }
            }
            
            // Return the total duration of all pauses in seconds
            return pauseInterval
        }
        
        private func testDeleteAddPause(identifier: String, startPause: Date, finishPause: Date) {
            // Create a new Pause entity in the Core Data context
            let newPause = Pause(context: persistenceController.container.viewContext)
            
            // Assign a unique identifier to the newPause based on the current time, formatted as a string
            newPause.identifier = String(Date().formatted(date: .omitted, time: .standard))
            
            // Set the start time of the pause period for the newPause entity
            newPause.startPause = startPause
            
            // Set the finish time of the pause period for the newPause entity
            newPause.finishPause = finishPause
            
            // Add a pause to a  day
            model.addToPauses(newPause)
        }
        private func isChanged() {
            if selectedPause?.wrappedStartPause != pauseStartEdit || selectedPause?.wrappedFinishPause != pauseFinishEdit {
                selectedPause?.startPause = pauseStartEdit
                selectedPause?.finishPause = pauseFinishEdit
                persistenceController.save()
                testFuncPrint() // test purpose
            }
        }
        
        private func editSelectedPause() {
            if selectedPause != nil && ((selectedPause?.wrappedStartPause) != pauseStartEdit) || ((selectedPause?.wrappedFinishPause) != pauseFinishEdit) {
                modelPauses = model.arrPause
            }
        }
        
        private func testFuncPrint() {
            
            for pause in model.arrPause {
                print("ModelPauses // Start: \(pause.wrappedStartPause), Finish: \(pause.wrappedFinishPause)")
            }
            for pause in modelPauses {
                print("ArrayPauses: // Start: \(pause.wrappedStartPause), Finish: \(pause.wrappedFinishPause)")
            }
        }
        
    }
}
