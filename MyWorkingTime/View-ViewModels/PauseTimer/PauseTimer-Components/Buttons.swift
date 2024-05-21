//
//  SwiftUIView.swift
//  MyWorkTime
//
//  Created by Yordan Dimitrov on 05.05.24.
//

import SwiftUI

struct Buttons: View {
    @ObservedObject var viewModel: PauseTimerView.PauseTimerViewModel
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var body: some View {
        if verticalSizeClass == .compact {
            HStack(spacing: 20) {
                VStack {
                    if !viewModel.isStarted && !viewModel.isStopped {
                        Button {
                            viewModel.startTimer()
                        } label: {
                            Label("Start", systemImage: "play")
                                .frame(maxWidth: 120)
                        }
                        .disabled(viewModel.disableStart)
                    } else {
                        HStack(spacing: 20) {
                            Button {
                                viewModel.resetTimer()
                            } label: {
                                Label("Reset", systemImage: "arrow.circlepath")
                                    .frame(maxWidth: 120)
                            }
                            .tint(.orange)
                            Button {
                                viewModel.resumeTimer()
                            } label: {
                                Label("Resume", systemImage: "playpause")
                                    .frame(maxWidth: 120)
                            }
                            .disabled(!viewModel.isStopped || viewModel.elapsedTime == 0)
                        }
                    }
                    
                }
                Button {
                    viewModel.stopTimer()
                } label: {
                    Label("Stop", systemImage: "stop")
                        .frame(maxWidth: viewModel.isTimerRunning ? 120 : 100)
                }
                .tint(.red)
                .disabled(!viewModel.isStarted || viewModel.elapsedTime == 0)
            }
            .buttonStyle(BorderedProminentButtonStyle())
            .shadow(color: .black, radius: 2, x: -1, y: 1)
            .animation(.easeInOut, value: viewModel.isStarted || viewModel.isStopped)
        } else {
            VStack(spacing: 20) {
                VStack {
                    if !viewModel.isStarted && !viewModel.isStopped {
                        Button {
                            viewModel.startTimer()
                        } label: {
                            Label("Start", systemImage: "play")
                                .frame(maxWidth: 120)
                        }
                        .disabled(viewModel.disableStart)
                    } else {
                        HStack {
                            Button {
                                viewModel.resetTimer()
                            } label: {
                                Label("Reset", systemImage: "arrow.circlepath")
                                    .frame(maxWidth: 120)
                            }
                            .tint(.orange)
                            Button {
                                viewModel.resumeTimer()
                            } label: {
                                Label("Resume", systemImage: "playpause")
                                    .frame(maxWidth: 120)
                            }
                            .disabled(!viewModel.isStopped || viewModel.elapsedTime == 0)
                        }
                    }
                    
                }
                Button {
                    viewModel.stopTimer()
                } label: {
                    Label("Stop", systemImage: "stop")
                        .frame(maxWidth: viewModel.isTimerRunning ? 120 : 100)
                }
                .tint(.red)
                .disabled(!viewModel.isStarted || viewModel.elapsedTime == 0)
            }
            .buttonStyle(BorderedProminentButtonStyle())
            .shadow(color: .black, radius: 2, x: -1, y: 1)
            .animation(.easeInOut, value: viewModel.isStarted || viewModel.isStopped)
        }
    }
}

#Preview {
    Buttons(viewModel: PauseTimerView.PauseTimerViewModel())
}


//VStack(spacing: 20) {
//    VStack {
//        if !viewModel.isStarted && !viewModel.isStopped {
//            Button {
//                viewModel.startTimer()
//            } label: {
//                Label("Start", systemImage: "play")
//                    .frame(maxWidth: 120)
//            }
//            .disabled(viewModel.disableStart)
//        } else {
//            HStack {
//                Button {
//                    viewModel.resetTimer()
//                } label: {
//                    Label("Reset", systemImage: "arrow.circlepath")
//                        .frame(maxWidth: 120)
//                }
//                .tint(.orange)
//                Button {
//                    viewModel.resumeTimer()
//                } label: {
//                    Label("Resume", systemImage: "playpause")
//                        .frame(maxWidth: 120)
//                }
//                .disabled(!viewModel.isStopped || viewModel.elapsedTime == 0)
//            }
//        }
//        
//    }
//    Button {
//        viewModel.stopTimer()
//    } label: {
//        Label("Stop", systemImage: "stop")
//            .frame(maxWidth: viewModel.isTimerRunning() ? 120 : 100)
//    }
//    .tint(.red)
//    .disabled(!viewModel.isStarted || viewModel.elapsedTime == 0)
//}
//.buttonStyle(BorderedProminentButtonStyle())
//.shadow(color: .black, radius: 2, x: -1, y: 1)
//.animation(.easeInOut, value: viewModel.isStarted || viewModel.isStopped)
