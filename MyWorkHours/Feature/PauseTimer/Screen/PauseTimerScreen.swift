//
//  Test.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 05.01.24.
//

import SwiftUI
import UserNotifications


struct PauseTimerScreen: View {
    
    @Environment(\.requestReview) private var requestReview
    @AppStorage("isReviewRequested") var isReviewRequested: Bool = false
    /// An identifier for the three-step process the person completes before this app chooses to request a review.
    @AppStorage("processCompletedCount") var processCompletedCount: Int = 0
    /// The most recent app version that prompts for a review.
    @AppStorage("lastVersionPromptedForReview") var lastVersionPromptedForReview = ""
    @State private var currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @StateObject var viewModel: PauseTimerViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                TimerView(viewModel: viewModel)
                Buttons(viewModel: viewModel)
            }
            .navigationTitle(verticalSizeClass == .compact ? "" : "Timer")
            .navigationBarTitleDisplayMode(.inline)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onChange(of: processCompletedCount) { _, _ in
            print("CompleteCount: \(processCompletedCount)")
            /*
             The lastVersionPromptedForReview property stores the version of the app that last prompts for a review.
             The app presents the rating and review request view if the person completed the three-step process at least four times and
             its current version is different from the version that last prompted them for review.
             */
            if processCompletedCount >= 5, currentAppVersion != lastVersionPromptedForReview {
                presentReview()
                
                // The app already displayed the rating and review request view. Store this current version.
                lastVersionPromptedForReview = currentAppVersion
            }
        }
        .onAppear {
#if DEBUG
            processCompletedCount = 0
            lastVersionPromptedForReview = ""
#endif
            if processCompletedCount >= 50 {
                processCompletedCount = 0
                lastVersionPromptedForReview = ""
            }
        }
    }
    
    /// Presents the rating and review request view after a two-second delay.
    private func presentReview() {
        Task {
            // Delay for two seconds to avoid interrupting the person using the app.
            try await Task.sleep(for: .seconds(2))
            requestReview()
        }
    }
    
    init(timerManager: TimerManager) {
        _viewModel = StateObject(wrappedValue: PauseTimerViewModel(timerManager: timerManager))
    }
}

#Preview {
    PauseTimerScreen(timerManager: TimerManager(workingDaysQueryService: WorkingDaysQueryService(persistenceController: PersistenceController.shared), workingDayPauseService: WorkingDayPauseService(persistenceController: PersistenceController.shared), userDefaultsStore: UserDefaultsStore(), notificationCenterServices: NotificationCenterServices()))
}
