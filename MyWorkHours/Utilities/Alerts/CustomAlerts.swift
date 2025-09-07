//
//  WTError.swift
//  MyWorkTime
//
//  Created by Yordan Dimitrov on 09.05.24.
//

import Foundation
import SwiftUI

enum CustomAlerts: Error, LocalizedError , Equatable {
    case emptyCompanyName
    case notCorrectTime
    case saved
    case dayExist
    case deleteAll
    case swipeDelete
    case userDefaultsIsEmpty
    case pauseWillBeNotAdded
    
    
    var title: LocalizedStringKey {
        switch self {
        case .emptyCompanyName:
            return "Unable to save your settings"
        case .notCorrectTime:
            return "Unable to save your settings"
        case .saved:
            return "Saved"
        case .dayExist:
            return "The day cannot be added"
        case .deleteAll:
            return "Are you sure?"
        case .swipeDelete:
            return "Are you sure?"
        case .userDefaultsIsEmpty:
            return "Workday could not be created"
        case .pauseWillBeNotAdded:
            return "The timer will not start!"
        }
    }
    
    var message: LocalizedStringKey {
        switch self {
        case .emptyCompanyName:
            return "Please make sure all textfields are filled in."
        case .notCorrectTime:
            return "Please make sure that the working hours are filled in correctly, they should be between 1 - 8 hours"
        case .saved:
            return "Your settings has been saved."
        case .dayExist:
            return "The day you are trying to add already exists in your list."
        case .deleteAll:
            return "If you click 'Delete', all selected items will be deleted. Once you click 'Delete', the operation cannot be undo"
        case .swipeDelete:
            return "If you click 'Delete', selected item will be deleted. Once you click 'Delete', the operation cannot be undo"
        case .userDefaultsIsEmpty:
            return "It's looks like your settings are not filled in correctly. Please check your settings and try again to create a workday."
        case .pauseWillBeNotAdded:
            return "The day with date \(Date().formatted(date: .abbreviated, time: .omitted)) doesn't exist in your worklist, please add the day and then try to start the timer."
        }
    }
}
