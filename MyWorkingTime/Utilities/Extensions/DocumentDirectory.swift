//
//  FileManager-DocumentsDirectory.swift
//  PlusStunde
//
//  Created by Yordan Dimitrov on 25.12.23.
//

import Foundation

extension FileManager {
    static var documentDirectory: URL {
        let path =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
}
