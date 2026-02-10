//
//  UserStatusStore.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 05.10.25.
//

import Combine
import Foundation

@MainActor
class UserStatusStore: ObservableObject {
    @Published private(set) var userStatus: UserStatus = .basic
    
    private var cancellables: Set<AnyCancellable> = []
    private var userDefaultsStore: UserDefaultsStore
    
    init(userDefaultsStore: UserDefaultsStore) {
        self.userDefaultsStore = userDefaultsStore
        subscribeAndUpdateUserStatus()
        retrieveUserDefaults()
    }
    
    // MARK: - Public Methods
    
    func subscribed() {
        userStatus = .subscribed
    }
    
    func basic() {
        userStatus = .basic
    }
    
    // MARK: - Private Methods
    
    //
    private func subscribeAndUpdateUserStatus() {
        $userStatus
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveInUserDefaults()
            }
            .store(in: &cancellables)
    }
    
    // Save user status into user defaults
    private func saveInUserDefaults() {
        try? userDefaultsStore.set(userStatus.rawValue, forKey: "userStatus")
        print("Saved \(userStatus.rawValue)")
    }
    
    
    // Retrieve user status from user defaults
    private func retrieveUserDefaults() {
        if let value = try? userDefaultsStore.get(UserStatus.RawValue.self, forKey: "userStatus", "basic"),
           let status = UserStatus(rawValue: value) {
            userStatus = status
        }
        print("Retrieved user status: \(userStatus.rawValue)")
    }

}
