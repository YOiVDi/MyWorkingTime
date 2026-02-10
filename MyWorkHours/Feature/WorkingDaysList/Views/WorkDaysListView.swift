import SwiftUI

struct WorkDaysListView: View {
    
    @ObservedObject var viewModel: WorkDaysScreen.ViewModel
    @Environment(\.editMode) var editMode
    
    var body: some View {
        // MARK: - List
        VStack {
            ZStack {
                // MARK: - List
                ListView(viewModel: viewModel)
                
                // MARK: - Card View
                if viewModel.showCheckInOutCard {
                    CheckInOutCardView(viewModel: viewModel)
                        .transition(.move(edge: .trailing))
                }
                
                // MARK: - Card Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            withAnimation {
                                viewModel.showCheckInOutCard.toggle()
                            }
                        } label: {
                            Image(systemName: "person.text.rectangle.fill")
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(.blue)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
        }
        .sheet(isPresented: $viewModel.createNewDaySheet) {
            CreateNewDayView(viewModel: viewModel)
        }
        
        // MARK: - Toolbar
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(SortByWorkDay.allCases, id: \.self) { choice in
                        Button {
                            viewModel.sortBy = choice
                        } label: {
                            HStack {
                                if choice == viewModel.sortBy {
                                    Image(systemName: "checkmark")
                                    Text(choice.rawValue)
                                } else { Text(choice.rawValue) }
                            }
                        }
                    }
                } label: {
                    Label("SortBy", systemImage: "arrow.up.arrow.down")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if editMode?.wrappedValue.isEditing == false {
                    Button {
                        viewModel.createNewDaySheet = true
                    } label: {
                        Label("add", systemImage: "plus.circle.fill")
                    }
                } else {
                    Button(role: .destructive) {
                        viewModel.pendingSelections = viewModel.selections
                        withAnimation {
                            viewModel.alert = .deleteAll
                            editMode?.wrappedValue = .inactive
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .onAppear {
            // Reset selections when the view appears
            viewModel.selections.removeAll()
            editMode?.wrappedValue = .inactive
        }
        .onDisappear {
            viewModel.showCheckInOutCard = false
        }
        .alert(viewModel.alert?.title ?? "Error Occured" , isPresented: Binding(value: $viewModel.alert)) {
            //            Buttons
            let buttons = viewModel.alertButtons(editMode)
            ForEach(0..<buttons.count, id: \.self) { i in
                Button(buttons[i].title, role: buttons[i].role) {
                    buttons[i].action()
                }
            }
        } message: {
            Text(viewModel.alert?.message ?? "")
        }
    }
}


#Preview {
    NavigationView {
        WorkDaysListView(viewModel: WorkDaysScreen.ViewModel(userStatusManager: UserStatusStore(userDefaultsStore: UserDefaultsStore()), servicesContainer: ServicesContainer(persistenceController: PersistenceController.shared)))
    }   
}
