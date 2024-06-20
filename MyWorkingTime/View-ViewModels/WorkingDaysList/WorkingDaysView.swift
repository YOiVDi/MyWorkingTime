//
//  WorkingDaysList.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 17.12.23.
//

import CoreData
import SwiftUI

struct WorkingDaysView: View {
    
    // MARK: Properties
    @StateObject var viewModel = ViewModel()
    private var emptyViewMessage: LocalizedStringKey = "Your working list is empty. To add a working day, use the button below."
    
    var body: some View {
        NavigationView {
            // MARK: - Main Stack
            ZStack(alignment: .bottomTrailing) {
                if viewModel.workingDaysList.isEmpty {
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
                            }
                            .font(.system(size: 40))
                            .confirmationDialog("Want to create a working day with date:", isPresented: $viewModel.confirmationIsShowing, titleVisibility: .visible) {
                                Button("Today", action: { viewModel.addWorkingDay() })
                                Button("Different Date", action: { viewModel.createNewDaySheet = true })
                            }
                        }
                    }
                    .sheet(isPresented: $viewModel.createNewDaySheet) {
                        CreateNewDayView(viewModel: viewModel)
                    }
                } else {
                    // MARK: - ListView
                    WorkingDaysListView(viewModel: viewModel)
                }
            }
            .animation(.easeInOut, value: viewModel.workingDaysList.isEmpty)
            .frame(maxHeight: .infinity)
            .navigationTitle("Working Hours")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    WorkingDaysView()
}
