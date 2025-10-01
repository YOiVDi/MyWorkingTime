//
//  WordaySettingsView.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 29.09.25.
//

import SwiftUI

struct WorkdaySettingsView: View {
    @Binding var companyName: String
    @Binding var startShift: Date
    @Binding var endShift: Date
    @Binding var workOnWeekend: Bool
    @Binding var saturday: Bool
    @Binding var startInSaturday: Date
    @Binding var endInSaturday: Date
    @Binding var sunday: Bool
    @Binding var startInSunday: Date
    @Binding var endInSunday: Date
    
    var body: some View {
            Section ("Work Information") {
                TextField("Company name", text: $companyName)
                    .autocorrectionDisabled()
                    .trimmedString($companyName)
                DatePicker("Start Shift", selection: $startShift, displayedComponents: .hourAndMinute)
                DatePicker("End Shift", selection: $endShift, displayedComponents: .hourAndMinute)
            }
            
            Section("Weekend's") {
                Toggle("Work on weekends", isOn: $workOnWeekend)
                
                if workOnWeekend {
                    Toggle("Saturday", isOn: $saturday)
                    if saturday {
                        DatePicker("Start Shift", selection: $startInSaturday, displayedComponents: .hourAndMinute)
                        DatePicker("End Shift", selection: $endInSaturday, displayedComponents: .hourAndMinute)
                    }
                    Toggle("Sunday", isOn: $sunday)
                    if sunday {
                        DatePicker("Start Shift", selection: $startInSunday, displayedComponents: .hourAndMinute)
                        DatePicker("End Shift", selection: $endInSunday, displayedComponents: .hourAndMinute)
                    }
                }
            }
    }
}

#Preview {
    WorkdaySettingsView(companyName: .constant("Company Name"), startShift: .constant(Date()), endShift: .constant(Date()), workOnWeekend: .constant(false), saturday: .constant(false), startInSaturday: .constant(Date()), endInSaturday: .constant(Date()), sunday: .constant(false), startInSunday: .constant(Date()), endInSunday: .constant(Date()))
}
