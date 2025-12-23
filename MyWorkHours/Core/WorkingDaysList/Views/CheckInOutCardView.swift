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
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),   // deep navy
                    Color(red: 0.18, green: 0.00, blue: 0.35)    // rich purple
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
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
                            .font(Font.system(size: 16, design: .monospaced))
                    } else {
                        Text("Check-In: No Check-In Time")
                            .lineLimit(1)
                    }
                    
                    /// Handel Check-Out
                    if let checkOut = viewModel.todayCheckInCheckOut?.checkOut {
                        Text("Check-Out: \(checkOut.formatted(.dateTime.hour().minute().second()))")
                            .font(Font.system(size: 16, design: .monospaced))
                    } else {
                        Text("Check-Out: No Check-Out Time")
                            .lineLimit(1)
                    }
                }
                .foregroundStyle(.white)
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
        }
        .frame(maxWidth: 375, maxHeight: 230)
        //        .background(colorScheme == .light ? .cyan : .gray)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 0.2)
                .backgroundStyle(.gray)
        )
        .onAppear(perform: { viewModel.assingDayForCheckInCheckOut()})
    }
}

#Preview {
    let persistenceController = PersistenceController.shared
    let userStatusManager = UserStatusManager(userDefaultsStore: UserDefaultsStore())
    CheckInOutCardView(viewModel: WorkDaysScreen.ViewModel(persistenceController: persistenceController, userStatusManager: userStatusManager))
}
