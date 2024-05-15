//
//  ToolBar.swift
//  WorkingHours
//
//  Created by Yordan Dimitrov on 29.03.24.
//

import SwiftUI

struct WorkingDaysListView: View {
    
    @ObservedObject var viewModel: WorkingDaysView.ViewModel
    @State private var selections = Set<WorkingDay>()
    @State private var pendingSelections = Set<WorkingDay>()
    @Environment(\.editMode) var editMode
    
    var body: some View {
        // MARK: - List
        List(selection: $selections) {
            ForEach(viewModel.workingDaysList, id: \.self) { workingDay in
                NavigationLink(destination: DetailView(model: workingDay)) {
                    VStack(alignment: .leading) {
                        HStack(spacing: 10) {
                            DateIconView(model: workingDay)
                            Text(workingDay.wrappedCompanyname)
                                .font(.title3).bold()
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.black.opacity(0))
            }
            .onDelete(perform: withAnimation(.smooth) {
                viewModel.delete })
            .onMove(perform: withAnimation(.smooth) {
                viewModel.move })
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollContentBackground(.hidden)
        .listRowSpacing(10)
        .background(Color.backGround)
        // MARK: - Toolbar
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                if editMode?.wrappedValue.isEditing == false {
                    Button {
                        viewModel.add()
                    } label: {
                        Label("add", systemImage: "plus.circle.fill")
                    }
                } else {
                    Button(role: .destructive) {
                        pendingSelections = selections
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
            selections.removeAll()
            editMode?.wrappedValue = .inactive
        }
        .alert(viewModel.alert?.title ?? "Error Occured" , isPresented: Binding(value: $viewModel.alert)) {
            if viewModel.alert == .deleteAll {
                Button("Yes", role: .destructive) {
                    viewModel.selectionDelete(pendingSelections)
                    selections.removeAll()
                    editMode?.wrappedValue = .inactive
                    pendingSelections.removeAll()
                }
                Button("Cancel", role: .cancel) {
                    withAnimation {
                        editMode?.wrappedValue = .active
                    }
                    selections = pendingSelections
                }
            }
        } message: {
            Text(viewModel.alert?.message ?? "")
        }
    }
}
    
    
#Preview {
        NavigationStack {
            WorkingDaysListView(viewModel: WorkingDaysView.ViewModel())
        }
    }

