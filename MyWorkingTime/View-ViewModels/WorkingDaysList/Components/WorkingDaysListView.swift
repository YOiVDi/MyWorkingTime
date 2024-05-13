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
                        Label("add", systemImage: "plus.circle")
                    }
                } else {
                    Button(role: .destructive) {
                        viewModel.selectionDelete(selections)
                        editMode?.wrappedValue = .inactive
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
}
    
    
#Preview {
        NavigationStack {
            WorkingDaysListView(viewModel: WorkingDaysView.ViewModel())
        }
    }

