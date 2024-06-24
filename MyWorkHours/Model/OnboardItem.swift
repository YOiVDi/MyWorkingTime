//
//  OnBoard.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 10.06.24.
//

import Foundation
import SwiftUI

struct OnboardItem: Identifiable {
    var id = UUID()
    var image: Image
    var title: LocalizedStringKey
    var content: LocalizedStringKey
    
    static var dummyItem =
        OnboardItem(image: Image(systemName: "pencil.and.list.clipboard"), title: "Just One Click", content: "You can add today as a working day or choose a specific date, all with just a few clicks on your smartphone.")
}

extension OnboardItem: Hashable {
    func hash(into hasher: inout Hasher) {
    }
}
