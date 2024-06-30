//
//  ToolBar.swift
//  WorkingHours
//
//  Created by Yordan Dimitrov on 29.03.24.
//

import SwiftUI

struct WorkingDaysListView: View {
    
    @ObservedObject var viewModel: WorkingDaysView.ViewModel
    @Environment(\.editMode) var editMode
    
    var body: some View {
        // MARK: - List
        ZStack {
            List(selection: $viewModel.selections) {
                ForEach(viewModel.workingDaysList, id: \.self) { workingDay in
                    NavigationLink(destination: DetailView(model: workingDay, persistenceController: viewModel.persistenceController)) {
                        VStack(alignment: .leading) {
                            HStack(spacing: 10) {
                                DateIconView(model: workingDay)
                                Text(workingDay.wrappedCompanyname)
                                    .font(.title3).bold()
                            }
                        }
                        .swipeActions(allowsFullSwipe: false) {
                            Button {
                                viewModel.singleSelect = workingDay
                                viewModel.alert = .swipeDelete
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .tint(.red)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.black.opacity(0))
                }

            }
//            .scrollBounceBehavior(.basedOnSize)
            .scrollContentBackground(.hidden)
            .listRowSpacing(10)
//            .confirmationDialog("Want to create a working day with date:", isPresented: $viewModel.confirmationIsShowing, titleVisibility: .visible) {
//                Button("Today", action: { viewModel.addWorkingDay() })
//                Button("Different Date", action: { viewModel.createNewDaySheet = true })
//            }
            
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
//                .padding(.horizontal, 40)
                .padding(.horizontal)
            }
//            .padding(.bottom, 70)
            .padding(.bottom)
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
                if editMode?.wrappedValue.isEditing == false {
                    Button {
                        viewModel.confirmationIsShowing = true
                    } label: {
                        Label("add", systemImage: "plus.circle.fill")
                    }
                    .confirmationDialog("Want to create a working day with date:", isPresented: $viewModel.confirmationIsShowing, titleVisibility: .visible) {
                        Button("Today", action: { viewModel.addWorkingDay() })
                        Button("Different Date", action: { viewModel.createNewDaySheet = true })
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
            viewModel.alertButtons(editMode)
        } message: {
            Text(viewModel.alert?.message ?? "")
        }
    }
}


#Preview {
    NavigationView {
        let persistenceController = PersistenceController.shared
        WorkingDaysListView(viewModel: WorkingDaysView.ViewModel(persistenceController: persistenceController))
    }
}

