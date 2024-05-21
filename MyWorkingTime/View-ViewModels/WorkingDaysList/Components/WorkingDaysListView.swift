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
        List(selection: $viewModel.selections) {
            ForEach(viewModel.workingDaysList, id: \.self) { workingDay in
                NavigationLink(destination: DetailView(model: workingDay)) {
                    VStack(alignment: .leading) {
                        HStack(spacing: 10) {
                            DateIconView(model: workingDay)
                            Text(workingDay.wrappedCompanyname)
                                .font(.title3).bold()
                        }
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button {
                            viewModel.singeleSelect = workingDay
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
            //            .onDelete(perform: withAnimation(.smooth) {
            //                viewModel.deleteWorkingDay })
            .onMove(perform: withAnimation(.smooth) {
                viewModel.moveWorkingDay })
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollContentBackground(.hidden)
        .listRowSpacing(10)
        .confirmationDialog("Want to create a working day with date:", isPresented: $viewModel.confirmationIsShowing, titleVisibility: .visible) {
            Button("Today", action: { viewModel.addWorkingDay() })
            Button("My choose", action: { viewModel.createNewDaySheet = true })
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
        .alert(viewModel.alert?.title ?? "Error Occured" , isPresented: Binding(value: $viewModel.alert)) {
            Button("Delete", role: .destructive) {
                handleDeleteAction()
            }
            Button("Cancel", role: .cancel) {
                handleCancelAction()
            }
            
//            Button("Delete", role: .destructive) {
//                if viewModel.alert == .deleteAll {
//                    viewModel.deleteSelectedWorkingDays(viewModel.pendingSelections)
//                    viewModel.selections.removeAll()
//                    editMode?.wrappedValue = .inactive
//                    viewModel.pendingSelections.removeAll()
//                    viewModel.alert = nil
//                } else if viewModel.alert == .swipeDelete {
//                    guard let selection = viewModel.singeleSelect else { return }
//                    viewModel.deleteWorkingDay2(day: selection)
//                    viewModel.singeleSelect = nil
//                    viewModel.alert = nil
//                }
//            }
//            
//            Button("Cancel", role: .cancel) {
//                if viewModel.alert == .deleteAll {
//                    withAnimation {
//                        editMode?.wrappedValue = .active
//                    }
//                    viewModel.selections = viewModel.pendingSelections
//                    viewModel.alert = nil
//                } else if viewModel.alert == .swipeDelete {
//                    viewModel.alert = nil
//                }
//            }
            
        } message: {
            Text(viewModel.alert?.message ?? "")
        }
    }
    
    private func handleDeleteAction() {
           switch viewModel.alert {
           case .deleteAll:
               viewModel.deleteSelectedWorkingDays(viewModel.pendingSelections)
               viewModel.selections.removeAll()
               editMode?.wrappedValue = .inactive
               viewModel.pendingSelections.removeAll()
           case .swipeDelete:
               if let selection = viewModel.singeleSelect {
                   viewModel.deleteWorkingDay2(day: selection)
                   viewModel.singeleSelect = nil
               }
           default:
               break
           }
           viewModel.alert = nil
       }
    
    private func handleCancelAction() {
        switch viewModel.alert {
        case .deleteAll:
            withAnimation {
                editMode?.wrappedValue = .active
            }
            viewModel.selections = viewModel.pendingSelections
        default:
            break
        }
        viewModel.alert = nil
    }
}


#Preview {
    NavigationStack {
        WorkingDaysListView(viewModel: WorkingDaysView.ViewModel())
    }
}

