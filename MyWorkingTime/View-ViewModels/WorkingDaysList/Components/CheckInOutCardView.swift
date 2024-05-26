//
//  CechInOutCard.swift
//  MyWorkingTime
//
//  Created by Yordan Dimitrov on 22.05.24.
//

import SwiftUI

struct CheckInOutCardView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: WorkingDaysView.ViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.userSettings?.companyName ?? "No Company")
                    .foregroundColor(.white)
                    .font(.title.bold())
            }
            .padding(.top, 10)
            .padding(.horizontal)
            Spacer()
            
            VStack(spacing: 20) {
                Text("Check-In: \(viewModel.checkIn)")
                Text("Check-Out: \(viewModel.checkOut)")
            }
            .padding(.bottom)
            
            HStack {
                Button {
                    viewModel.handleCheckIn()
                } label: {
                    Text("Check-In")
                        .bold()
                        .frame(width: 100, height: 30)
                }
                .tint(.blue)
                .disabled(viewModel.checkIn != "No check-in time")
                
                Button(role: .destructive) {
                    viewModel.handleCheckOut()
                } label: {
                    Text("Check-Out")
                        .bold()
                        .frame(width: 100, height: 30)
                }
                .disabled(viewModel.checkOut != "No check-out time")
            }
            .padding()
            .buttonStyle(BorderedProminentButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: 230)
        .background(colorScheme == .light ? .cyan : .gray)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
        .onAppear(perform: { viewModel.doesTodayExist()})
    }
}

#Preview {
    CheckInOutCardView(viewModel: WorkingDaysView.ViewModel())
}
