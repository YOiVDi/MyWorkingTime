//
//  DetailViewViewModel.swift
//  MyWorkTime
//
//  Created by Yordan Dimitrov on 09.05.24.
//

import CoreData
import SwiftUI

extension DetailView {
    class ViewModel: ObservableObject {
        // MARK: - Public properties
        @Published var selectedPause: Pause?
        @Published var model: WorkingDay
        @Published var onChange: Bool = false
        @Published var addNewPause: Bool = false
        
        @Published var pauseBegin: Date
        @Published var pauseEnd: Date
        
        @Published var checkIn: Date
        @Published var checkOut: Date

        
        var pauseDescription: String {
            if pauseBegin <= checkIn {
                return "Pause cannot be added. The pause start time must be after check-in."
            }
            if pauseBegin >= checkOut {
                return "Pause cannot be added. The pause start time must be before check-out."
            }
            if pauseBegin >= pauseEnd {
                return "Pause cannot be added. The pause start time must be earlier than the pause end time."
            }
            if pauseEnd >= checkOut {
                return "Pause cannot be added. The pause end time must be before check-out."
            }
            return "" // no errors
        }
        
        // MARK: - Private properties
        private var defaultTime = Calendar(identifier: .gregorian).date(bySettingHour: 0, minute: 00, second: 0, of: Date()) ?? Date()
        private var time = "Check-In and Check-Out data missing."
        
        private let persistenceController: PersistenceController
        private let workTimeAsInt = WorkTimeAsInt()
        
        // MARK: - Computed properties
        
        /// disable add pause button.
        var disableAddPause: Bool {
            return selectedPause == nil &&  model.arrPause.count == 4
        }
        
        /// expose pause for certain WorkDay
        var modelPauses: [Pause] { model.arrPause }
        
        /// show complete worked time for a day.
        var workedTime: String {
            model.workedTime != 0 ? convertTimeToSeconds(model.wrappedWorkedTime) : time
        }
        
        
        
        // MARK: - Initialization
        init(model: WorkingDay, persistenceController: PersistenceController) {
            /// init persistenceController
            self.persistenceController = persistenceController
            /// init properties
            self.model = model
            self.pauseBegin = defaultTime
            self.pauseEnd = defaultTime
            self.checkIn = model.wrappedCheckIn ?? defaultTime
            self.checkOut = model.wrappedCheckOut ?? defaultTime
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
                        if self.addNewPause == false {
                        }
                        self.addNewPause.toggle()
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                }
            }
        }
        
        /// Deletes the given pause from the working day and saves the context.
        func deletePause() {
            guard let selectedPause else { return }
            
            // Delete selected pause from Core Data context
            persistenceController.deletePause(selectedPause)
            
            // Set selectedpause to nil
            self.selectedPause = nil
            
            // Recalculate the working time (assuming this function exists and performs some calculation)
            calculatedWorkingTime()
        
            // Save the changes to the persistence controller
            persistenceController.save()
        }
        
        
        /// Updates the working day and optionally the pause with the new values.
        func update() {
            // Update the model's working hours, check-in, and check-out times
            model.checkIn = self.checkIn == defaultTime ? nil : self.checkIn
            model.checkOut = self.checkOut == defaultTime ? nil : self.checkOut
            
            // Reset the selected pause to nil
            selectedPause = nil
            
            // Recalculate the working time (assuming this function exists and performs some calculation)
            calculatedWorkingTime()
            
            objectWillChange.send()
            
            // Save the changes to the persistence controller
            persistenceController.save()
        }
        
        /// Adds a new pause to the working day.
        func addPause(for day: WorkingDay) {
            
            let addStartPause = pauseBegin
            // Initialize pauseStartEdit to the current date and time + 15 min
//            let addFinishPause = Date(timeInterval: 900, since: addStartPause)
            let addFinishPause = pauseEnd
            
            // Create a new Pause entity in the Core Data context
            let newPause = Pause(context: persistenceController.container.viewContext)
            
            // Assign a unique identifier to the newPause
            newPause.identifier = UUID().uuidString
            
            // Set the start time of the pause period for the newPause entity
            newPause.startPause = addStartPause
            
            // Set the finish time of the pause period for the newPause entity
            newPause.finishPause = addFinishPause
            
            // Add a pause to a  day
            day.addToPauses(newPause)

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
                print("selectedPause: \(pauseBegin) \(pauseEnd)")
                print("selectedPause: \(pause.wrappedStartPause) \(pause.wrappedFinishPause)")
                selectedPause = pause
                pauseBegin = pause.wrappedStartPause
                pauseEnd = pause.wrappedFinishPause
            }
        }
        
        
        /// Calculate time between check-in and check-out.
        /// - Returns: return calculated time.
        func calculatedWorkingTime() {
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
                if model.wrappedWorkedTime != totalSeconds {
                    model.workedTime = Int64(totalSeconds)
                    persistenceController.save()
                }
                
                // Calculate and format the time as a string.
                self.time = convertTimeToSeconds(totalSeconds)
            }
        }
        
        /// Convert Int16 from coredate into hours, minutes.
        func calculateWorkTimeFromMinutes() -> String {
            let hours = model.workingHours / 60
            let minutes = model.workingHours % 60
            return String(format: "%02d:%02d", hours, minutes)
        }
        
        /// Set a date of new pause  fields to match date of day
        func dateOfWorkDay() {
            let modelDate = model.wrappedDate
            var components = Calendar.current.dateComponents([.day, .month, .year ,.hour , .minute], from: modelDate)
            components.hour = 0
            components.minute = 0
            pauseBegin = Calendar.current.date(from: components) ?? Date()
            pauseEnd = Calendar.current.date(from: components) ?? Date()
            print("components: \(components)")
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
        
    }
}
