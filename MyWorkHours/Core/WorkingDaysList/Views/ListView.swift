//
//  ListView.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 05.10.25.
//

import SwiftUI

struct ListView: View {
    @ObservedObject var viewModel: WorkDaysScreen.ViewModel
    var body: some View {
        if viewModel.userStatusManager.userStatus == .subscribed {
            List(selection: $viewModel.selections) {
                ForEach(viewModel.section, id: \.self) { section in
                    Section("\(section.name)") {
                        ForEach(section.items, id: \.self) { workDay in
                            NavigationLink(destination: DetailScreen(model: workDay, modelPause: workDay.arrPause, persistenceController: viewModel.persistenceController)) {
                                VStack(alignment: .leading) {
                                    HStack(spacing: 10) {
                                        DateIconView(model: workDay)
                                        Text(workDay.wrappedCompanyname)
                                            .font(.title3).bold()
                                        Text(viewModel.calculateTime(workDay))
                                            .foregroundStyle((workDay.wrappedWorkedTime + viewModel.calculatePauseInSeconds(workDay)) - (workDay.wrappedWorkingHours * 60) < 0 ? Color.red :  Color.green)
                                    }
                                }
                                .swipeActions(allowsFullSwipe: false) {
                                    Button {
                                        viewModel.singleSelect = workDay
                                        viewModel.alert = .swipeDelete
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                            .tint(.red)
                                    }
                                }
                            }
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.black.opacity(0))
            }
            .scrollContentBackground(.hidden)
            .listRowSpacing(10)
            .animation(.easeInOut, value: viewModel.sortBy)
        } else {
            List {
                ForEach(viewModel.workDays, id: \.self) { workDay in
                    NavigationLink(destination: DetailScreen(model: workDay, modelPause: workDay.arrPause, persistenceController: viewModel.persistenceController)) {
                        VStack(alignment: .leading) {
                            HStack(spacing: 10) {
                                DateIconView(model: workDay)
                                Text(workDay.wrappedCompanyname)
                                    .font(.title3).bold()
                            }
                        }
                        .swipeActions(allowsFullSwipe: false) {
                            Button {
                                viewModel.singleSelect = workDay
                                viewModel.alert = .swipeDelete
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .tint(.red)
                            }
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.black.opacity(0))
            }
            .scrollContentBackground(.hidden)
            .listRowSpacing(10)
            .animation(.easeInOut, value: viewModel.sortBy)
        }
    }
    
}


#Preview {
    let persistenceController = PersistenceController.shared
    let userStatusManager = UserStatusManager(userDefaultsStore: UserDefaultsStore())
    ListView(viewModel: WorkDaysScreen.ViewModel(persistenceController: persistenceController, userStatusManager: userStatusManager))
}
