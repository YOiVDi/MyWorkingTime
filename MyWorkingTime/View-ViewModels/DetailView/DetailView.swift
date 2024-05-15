//
//  DayInformation.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 26.12.23.
//

import SwiftUI

struct DetailView: View {
    
    // MARK: Properties
    @State var model: WorkingDay
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        List {
            Group {
                // Company section
                companySection
                // WorkingHours section
                workingHoursSection
                // Pause Section
                pauseSection
            }
            .listRowBackground(Color.backGround)
//            .listRowSeparator(.hidden)
        }
        .listRowSpacing(10)
        .background(Color.backGround)
        .scrollContentBackground(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        
        
        // MARK: Edited Sheet
        .sheet(isPresented: $viewModel.onChange) {
                EditSheet(model: model, viewModel: viewModel)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    withAnimation {
                        viewModel.onChange = true
                    }
                } label: {
                    Text("Edit")
                }
            }
        }
        .navigationTitle("\(model.wrappedDate.formatted(.dateTime.day().month()))")
        .onDisappear(perform: {
            dismiss()
        })
    }
    
    private var companySection: some View {
        Section("Company") {
            Text(model.wrappedCompanyname)
                .font(.body)
                .fontWeight(.semibold)
        }
    }
    
    private var workingHoursSection: some View {
        Section("Working Hour's") {
//            Text("\(model.wrappedWorkingHours.formatted(date: .omitted, time: .shortened))")
            Text("\(model.WrappedWorkingHours)")
                .font(.body)
                .fontWeight(.semibold)
        }
    }
    
    private var pauseSection: some View {
        Section("Pause") {
            if model.arrPause.count != 0  {
                ForEach(0..<model.arrPause.count, id: \.self) { index in
                        HStack {
                                Text("Start: \(model.arrPause[index].wrappedStartPause.formatted(date: .omitted, time: .shortened))")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                Text("Finish: \(model.arrPause[index].wrappedFinishPause.formatted(date: .omitted, time: .shortened))")
                                    .font(.body)
                                    .fontWeight(.semibold)
                        }
                        .swipeActions {
                            let pause = model.arrPause[index]
                            Button("delete", role: .destructive) {
                                viewModel.deletePause(workingDay: model, pause: pause)
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        
        DetailView(model: PersistenceController.preview)
    }
}
