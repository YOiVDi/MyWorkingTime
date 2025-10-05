//
//  UnavailableView.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 01.07.24.
//


import SwiftUI

struct UnavailableView: View {
    @ObservedObject var viewModel: WorkDaysScreen.ViewModel
    private(set) var emptyViewMessage: LocalizedStringKey = "Your working list is empty. To add a working day, use the button below."
    
    
    
    var body: some View {
        VStack {
            ContentUnavailableView {
                Label("Your list is empty", systemImage: "scribble.variable")
            } description: {
                Text(emptyViewMessage)
            } actions: {
                Button {
                    viewModel.confirmationIsShowing = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 40))
                }
                .confirmationDialog("Want to create a working day with date:", isPresented: $viewModel.confirmationIsShowing, titleVisibility: .visible) {
                    Button("Today", action: { viewModel.addWorkingDay() })
                    Button("Different Date", action: { viewModel.createNewDaySheet = true })
                }
            }
        }
        .sheet(isPresented: $viewModel.createNewDaySheet) {
            CreateNewDayView(viewModel: viewModel)
        }
    }
}
