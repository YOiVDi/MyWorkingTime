//
//  OnboardSetupWork.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 28.12.25.
//

import SwiftUI

struct OnboardSetupWork: View {
    @Binding var companyName: String
    @Binding var startShift: Date
    @Binding var endShift: Date
    @Binding var pause: Date
    @Binding var workOnWeekend: Bool
    @Binding var saturday: Bool
    @Binding var startInSaturday: Date
    @Binding var endInSaturday: Date
    @Binding var pauseSaturday: Date
    @Binding var sunday: Bool
    @Binding var startInSunday: Date
    @Binding var endInSunday: Date
    @Binding var pauseSunday: Date
    
    var body: some View {
        VStack {
                Section {
                    HStack {
                        Text("Company: ")
                        TextField("Your company name", text: $companyName)
                            .autocorrectionDisabled()
                            .trimmedString($companyName)
                    }
                    DatePicker("Start Shift:", selection: $startShift, displayedComponents: .hourAndMinute)
                    DatePicker("End Shift:", selection: $endShift, displayedComponents: .hourAndMinute)
                    DatePicker("Pause:", selection: $pause, displayedComponents: .hourAndMinute)
                }
                .padding(.horizontal)
                .bold()
                
                Section("Weekend's") {
                    Toggle("Work on weekends", isOn: $workOnWeekend.animation())
                        .toggleStyle(ColoredSwitchToggleStyle())
                    
                    if workOnWeekend {
                        Toggle("Saturday", isOn: $saturday.animation())
                            .toggleStyle(ColoredSwitchToggleStyle())
                        if saturday {
                            DatePicker("Start Shift:", selection: $startInSaturday, displayedComponents: .hourAndMinute)
                            DatePicker("End Shift:", selection: $endInSaturday, displayedComponents: .hourAndMinute)
                            DatePicker("Pause:", selection: $pauseSaturday, displayedComponents: .hourAndMinute)
                        }
                        Toggle("Sunday", isOn: $sunday.animation())
                            .toggleStyle(ColoredSwitchToggleStyle())
                        if sunday {
                            DatePicker("Start Shift:", selection: $startInSunday, displayedComponents: .hourAndMinute)
                            DatePicker("End Shift:", selection: $endInSunday, displayedComponents: .hourAndMinute)
                            DatePicker("Pause:", selection: $pauseSunday, displayedComponents: .hourAndMinute)
                        }
                    }
                }
                .padding(.horizontal)
                .bold()
                Text("Please complete all fields correctly to ensure accurate daily data.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
        }
    }
    
}

#Preview {
    OnboardSetupWork(companyName: .constant("Company Name"), startShift: .constant(Date()), endShift: .constant(Date()), pause: .constant(Date()), workOnWeekend: .constant(true), saturday: .constant(false), startInSaturday: .constant(Date()), endInSaturday: .constant(Date()), pauseSaturday: .constant(Date()), sunday: .constant(false), startInSunday: .constant(Date()), endInSunday: .constant(Date()), pauseSunday: .constant(Date()))
}
