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
                if !viewModel.isTimerRunning() {
                    VStack {
                        Text("Set Timer")
                            .font(.title)
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
                        .onChange(of: viewModel.hours) { oldValue, newValue in
                            guard newValue != oldValue else {
                                return }
                            viewModel.setTimer()
                        }
                        .onChange(of: viewModel.minutes) { oldValue, newValue in
                            guard newValue != oldValue else {
                                return }
                            viewModel.setTimer()
                        }
                        .onChange(of: viewModel.seconds) { oldValue, newValue in
                            guard newValue != oldValue else {
                                return }
                            viewModel.setTimer()
                        }
                    }
                    .frame(width: 350)
                } else {
                    Text("\(viewModel.formatTime(viewModel.elapsedTime))")
                        .foregroundColor(.green)
                        .font(.largeTitle.bold())
                }
            }
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    viewModel.handleActiveScenePhase()
                    
                } else if scenePhase == .background {
                    viewModel.handleBackgroundScenePhase()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 400)
    }
}

#Preview {
    TimerView(viewModel: PauseTimerView.PauseTimerViewModel())
}
