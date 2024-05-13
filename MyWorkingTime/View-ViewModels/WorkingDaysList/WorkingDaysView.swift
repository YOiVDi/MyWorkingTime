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
    private var emptyMessage: String = "Your working list is empty. To add a working day, use the button below."
    
    var body: some View {
        NavigationView {
            // MARK: - Main Stack
            ZStack(alignment: .bottomTrailing) {
                if viewModel.workingDaysList.isEmpty {
                    VStack {
                        ContentUnavailableView {
                            Label("Your list is empty", systemImage: "scribble.variable")
                        } description: {
                            Text(emptyMessage)
                        } actions: {
                            Button("Click", action: viewModel.add)
                            .font(.title3)
                            .buttonStyle(BorderedProminentButtonStyle())
                        }
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
            .background(Color.backGround)
        }
    }
}

#Preview {
    WorkingDaysView()
}
