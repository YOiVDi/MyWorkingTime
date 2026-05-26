import SwiftUI

struct ListView: View {
    @ObservedObject var viewModel: WorkDaysScreen.ViewModel
    @Namespace var namespace
    var body: some View {
        if viewModel.isPremium {
            List(selection: $viewModel.selections) {
                ForEach(viewModel.section, id: \.self) { section in
                    Section("\(section.name)") {
                        ForEach(section.items, id: \.self) { workDay in
                            let detailVM = viewModel.makeDetailViewModel(for: workDay)
                            NavigationLink {
                                DetailScreen(viewModel: detailVM)
                                    .navigationTransition(.zoom(sourceID: workDay.id, in: namespace))
                            } label: {
                                VStack(alignment: .leading) {
                                    HStack(spacing: 10) {
                                        DateIconView(model: workDay)
                                        Text(workDay.companyName)
                                            .font(.title3).bold()
                                        Text(viewModel.calculateWorkTimeForTheDay(workDay))
                                            .foregroundStyle(viewModel.calculateWorkTimeForTheDay(workDay).contains("-") ? .red : .green)
                                    }
                                    .matchedTransitionSource(id: workDay.id, in: namespace)
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
