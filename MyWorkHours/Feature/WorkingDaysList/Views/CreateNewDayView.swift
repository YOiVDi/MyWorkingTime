import SwiftUI

struct CreateNewDayView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WorkDaysScreen.ViewModel
    var body: some View {
        NavigationView {
            VStack {
                Picker("Work Choice", selection: $viewModel.workChoice) {
                    ForEach(UserDefaultsKeys.allCases, id: \.self) { key in
                        Text(key == .firstWorkSettings ? viewModel.userFirstWorkSettings.companyName : viewModel.userSecondWorkSettings.companyName)
                            .onTapGesture {
                                viewModel.workChoice = key
                            }
                    }
                }
                .pickerStyle(.segmented)
                .disabled(viewModel.disableWorkChoice())

                HStack {
                    Text("Company name: ")
                        .fontWeight(.semibold)
                    Text(viewModel.workChoice == .firstWorkSettings ? viewModel.userFirstWorkSettings.companyName : viewModel.userSecondWorkSettings.companyName)
                    Spacer()
                }
                
                VStack {
                    DatePicker("Choose a day: ", selection: $viewModel.userDefinedWorkDay.date, displayedComponents: .date)
                }
                .fontWeight(.semibold)
                
                VStack {
                    Text("Working hour's: ")
                    DatePicker("Start Shift", selection: $viewModel.userDefinedWorkDay.startShift, displayedComponents: .hourAndMinute)
                    DatePicker("End Shift", selection: $viewModel.userDefinedWorkDay.endShift, displayedComponents: .hourAndMinute)
                }
                .fontWeight(.semibold)
                Text("When you create a new day with a specific date, you can add check-ins, check-outs, and pauses after the day is created. Simply click on the day you created in the upper right corner via the edit button, and you will be able to edit that day. From there, you can update your check-in and check-out times, as well as add pauses.")
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    viewModel.creatingDayOfUserChoice(dismiss)
                } label: {
                    Text("Create day")
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(.blue)
                        .cornerRadius(10)
                }
                .padding(.bottom)
            }
            .padding(.horizontal, 20)
            .navigationTitle("New working day")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("Back")
                        }
                    }
                }
            }
            .onAppear {
                viewModel.checkWeekday(viewModel.userDefinedWorkDay.date)
            }
            .onChange(of: viewModel.workChoice) { _, _ in
                viewModel.checkWeekday(viewModel.userDefinedWorkDay.date)
            }
            .onChange(of: viewModel.userDefinedWorkDay.date) { oldDate, newDate in
                viewModel.checkWeekday(viewModel.userDefinedWorkDay.date)
            }
        }
    }
}

#Preview {
    CreateNewDayView(viewModel: WorkDaysScreen.ViewModel(userStatusStore: UserStatusStore(userDefaultsStore: UserDefaultsStore()), servicesContainer: ServicesContainer(persistenceController: PersistenceController.shared)))
}
