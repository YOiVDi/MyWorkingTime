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
    
    
    var title: String {
        switch self {
        case .emptyCompanyName:
            return "Unable to save your settings"
        case .notCorrectTime:
            return "Unable to save your settings"
        case .saved:
            return "Saved"
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
        }
    }
}
