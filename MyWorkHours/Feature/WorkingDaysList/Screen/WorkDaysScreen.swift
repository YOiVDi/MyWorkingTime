import CoreData
import SwiftUI

struct WorkDaysScreen: View {
    
    // MARK: Properties
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        NavigationStack {
            // MARK: - Main Stack
            ZStack(alignment: .bottomTrailing) {
                if viewModel.workingDaysList.isEmpty {
                    UnavailableView(viewModel: viewModel)
                } else {
                    // MARK: - ListView
                    WorkDaysListView(viewModel: viewModel)
                }
            }
            .animation(.easeInOut, value: viewModel.workingDaysList.isEmpty)
            .frame(maxHeight: .infinity)
            .navigationTitle("Working Hours")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
    
    init(userStatusStore: UserStatusStore, servicesContainer: ServicesContainerProtocol) {
        _viewModel = StateObject(wrappedValue: ViewModel(userStatusStore: userStatusStore, servicesContainer: servicesContainer))
    }
}

#Preview {

    WorkDaysScreen(userStatusStore: UserStatusStore(userDefaultsStore: UserDefaultsStore()), servicesContainer: ServicesContainer(persistenceController: PersistenceController.shared))
}
