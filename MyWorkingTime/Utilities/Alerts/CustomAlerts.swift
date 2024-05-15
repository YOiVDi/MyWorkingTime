//
//  WTError.swift
//  MyWorkTime
//
//  Created by Yordan Dimitrov on 09.05.24.
//

import Foundation

enum CustomAlerts: Error, LocalizedError {
    case emptyCompanyName
    case notCorrectTime
    case saved
    case dayExist
    case deleteAll
    
    
    var title: String {
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
        }
    }
    
    var message: String {
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
            return "If you click 'Yes', all selected items will be deleted. Once you click 'Yes', the operation cannot be undone"
        }
    }
}
