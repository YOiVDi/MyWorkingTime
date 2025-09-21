//
//  SectionModel.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 21.09.25.
//

import Foundation

struct SectionModel: Identifiable, Hashable, Comparable {
    static func < (lhs: SectionModel, rhs: SectionModel) -> Bool {
        lhs > rhs
    }
    
    let id = UUID()
    let name: String
    let items: [WorkingDay]
    let date: Date
}
