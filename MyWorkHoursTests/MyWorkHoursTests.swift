//
//  MyWorkHoursTests.swift
//  MyWorkHoursTests
//
//  Created by Yordan Dimitrov on 26.11.24.
//

import XCTest
@testable import MyWorkHours

final class MyWorkHoursTests: XCTestCase {
    
    var sut: WorkDaysScreen.ViewModel!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        
        Task { @MainActor in
            self.sut = WorkDaysScreen.ViewModel(persistenceController: PersistenceController.shared)
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        sut = nil
    }
    
    

}
