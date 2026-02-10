import SwiftUI

struct ListView: View {
    @ObservedObject var viewModel: WorkDaysScreen.ViewModel
    var body: some View {
        if viewModel.isPremium {
            List(selection: $viewModel.selections) {
                ForEach(viewModel.section, id: \.self) { section in
                    Section("\(section.name)") {
                        ForEach(section.items, id: \.self) { workDay in
                            let detailVM = viewModel.makeDetailViewModel(for: workDay)
                            NavigationLink(destination: DetailScreen(viewModel: detailVM)) {
                                VStack(alignment: .leading) {
                                    HStack(spacing: 10) {
                                        DateIconView(model: workDay)
                                        Text(workDay.companyName)
                                            .font(.title3).bold()
                                        Text(viewModel.calculateTime(workDay))
                                            .foregroundStyle((workDay.workedTime + viewModel.calculatePauseInSeconds(workDay)) - (workDay.workHours * 60) < 0 ? Color.red :  Color.green)
                                    }
                                }
                                .swipeActions(allowsFullSwipe: false) {
                                    Button {
                                        withAnimation {
                                            viewModel.singleSelect = workDay
                                            viewModel.alert = .swipeDelete
                                        }
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
            List(selection: $viewModel.selections) {
                ForEach(viewModel.workDays, id: \.self) { workDay in
                    NavigationLink(destination: DetailScreen(viewModel: viewModel.makeDetailViewModel(for: workDay))) {
                        VStack(alignment: .leading) {
                            HStack(spacing: 10) {
                                DateIconView(model: workDay)
                                Text(workDay.companyName)
                                    .font(.title3).bold()
                            }
                        }
                        .swipeActions(allowsFullSwipe: false) {
                            Button {
                                withAnimation {
                                    viewModel.singleSelect = workDay
                                    viewModel.alert = .swipeDelete
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .tint(.red)
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
}


#Preview {
    
    ListView(viewModel: WorkDaysScreen.ViewModel(userStatusStore: UserStatusStore(userDefaultsStore: UserDefaultsStore()), servicesContainer: ServicesContainer(persistenceController: PersistenceController.shared)))
}
