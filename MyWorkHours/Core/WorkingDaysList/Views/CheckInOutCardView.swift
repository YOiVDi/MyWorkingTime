//
//  CechInOutCard.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 22.05.24.
//

import SwiftUI

struct CheckInOutCardView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: WorkDaysScreen.ViewModel
    
    var body: some View {
        VStack {
            Picker("", selection: $viewModel.workChoice) {
                ForEach(UserDefaultsKeys.allCases, id: \.self) { key in
                    Text(key == .firstWorkSettings ? (viewModel.userSettings?.companyName ?? "") : (viewModel.secondUserSettings?.companyName ?? ""))
                        .onTapGesture {
                            viewModel.workChoice = key
                        }
                }
            }
            .pickerStyle(.segmented)
            .padding([.top, .horizontal])
            .disabled(viewModel.disableWorkChoice())
            
            HStack {
                ///
                Text(viewModel.userSettings?.companyName ?? "No Company")
                    .foregroundColor(.white)
                    .font(.title.bold())
            }
            .padding(.top, 10)
            .padding(.horizontal)
            Spacer()
            
            VStack(spacing: 20) {
                /// Handel Check-In
                if let checkIn = viewModel.todayCheckInCheckOut?.checkIn{
                    Text("Check-In: \(checkIn.formatted(.dateTime.hour().minute().second()))")
                } else {
                    Text("Check-In: No Check-In Time")
                        .lineLimit(1)
                }
                
                /// Handel Check-Out
                if let checkOut = viewModel.todayCheckInCheckOut?.checkOut {
                    Text("Check-Out: \(checkOut.formatted(.dateTime.hour().minute().second()))")
                } else {
                    Text("Check-Out: No Check-Out Time")
                        .lineLimit(1)
                }
            }
            .padding(.bottom)
            
            HStack {
                Button {
                    viewModel.handleCheckIn()
                } label: {
                    Text("Check-In")
                        .bold()
                        .frame(width: 120, height: 30)
                }
                .tint(.blue)
                .disabled(viewModel.todayCheckInCheckOut?.checkIn != nil)
                
                Button(role: .destructive) {
                    viewModel.handleCheckOut()
                } label: {
                    Text("Check-Out")
                        .bold()
                        .frame(width: 120, height: 30)
                }
                .disabled(viewModel.todayCheckInCheckOut?.checkOut != nil)
            }
            .padding(.bottom)
            .buttonStyle(BorderedProminentButtonStyle())
        }
        .frame(maxWidth: 375, maxHeight: 230)
        .background(colorScheme == .light ? .cyan : .gray)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onAppear(perform: { viewModel.assingDayForCheckInCheckOut()})
    }
}

#Preview {
    let persistenceController = PersistenceController.shared
    let userStatusManager = UserStatusManager(userDefaultsStore: UserDefaultsStore())
    CheckInOutCardView(viewModel: WorkDaysScreen.ViewModel(persistenceController: persistenceController, userStatusManager: userStatusManager))
}
