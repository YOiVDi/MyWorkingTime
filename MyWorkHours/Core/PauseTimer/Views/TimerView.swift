//
//  TimerView.swift
//  MyWorkTime
//
//  Created by Yordan Dimitrov on 05.05.24.
//

import SwiftUI

struct TimerView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @ObservedObject var viewModel: PauseTimerView.PauseTimerViewModel
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .frame(width: 350, height: verticalSizeClass == .compact  ? 250 : 350)
                .foregroundStyle(.secondary)
                .overlay(
                    Circle()
                        .trim(from: 0 , to: viewModel.trimProgress)
                        .stroke(lineWidth: 20)
                        .frame(width: 350, height: verticalSizeClass == .compact  ? 250 : 350)
                        .foregroundStyle(viewModel.timerCircleColor)
                        .rotationEffect(Angle(degrees: -90))
                        .animation(.easeInOut, value: viewModel.elapsedTime)
                )
            
            VStack {
                if !viewModel.isTimerRunning {
                    VStack {
                        Text("Set Timer")
                            .font(.title2)
                        HStack {
                            VStack {
                                Picker("Hours.", selection: $viewModel.hours) {
                                    ForEach(0..<24, id: \.self) {
                                        Text("\($0)")
                                    }
                                }
                                Text("Hours")
                            }
                            VStack {
                                Picker("Min.", selection: $viewModel.minutes) {
                                    ForEach(0..<60, id: \.self) {
                                        Text("\($0)")
                                    }
                                }
                                Text("Min.")
                            }
                            VStack {
                                Picker("Sec.", selection: $viewModel.seconds) {
                                    ForEach(0..<60, id: \.self) {
                                        Text("\($0)")
                                    }
                                }
                                Text("Sec.")
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 100)
                        .padding(.horizontal, 80)
                        .padding(.bottom)
                    }
                    .frame(width: 350)
                } else {
                    if viewModel.isTimerRunning && viewModel.elapsedTime != 0 {
                        Text("\(viewModel.formatTime(viewModel.elapsedTime))")
                            .foregroundColor(.green)
                            .font(.largeTitle.bold())
                    } else {
                        Text("\(viewModel.formatTime(viewModel.overElapsedTime))")
                            .foregroundColor(.red)
                            .font(.largeTitle.bold())
                    }
                }
            }
            .onChange(of: scenePhase) {
                viewModel.handleScenePhaseChange(scenePhase)
            }
            .alert(viewModel.alert?.title ?? "Error Occur", isPresented: Binding(value: $viewModel.alert)) {
                
            } message: {
                Text(viewModel.alert?.message ?? "")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 400)
        VStack {
            Picker("", selection: $viewModel.predefinedTimer) {
                ForEach(PredefinedTimer.allCases, id: \.self) { timer in
                    Text("\(timer.rawValue)")
                        .tag(timer)
                }
                
            }
            .pickerStyle(.segmented)
            .disabled(viewModel.isStarted)
            .onChange(of: viewModel.predefinedTimer) { oldValue, newValue in
                viewModel.predifenedTimerSelected()
            }
        }
        .frame(width: 350)
    }
}

#Preview {
    TimerView(viewModel: PauseTimerView.PauseTimerViewModel(timerManager: TimerManager(persistenceController: PersistenceController.shared)))
}
