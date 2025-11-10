//
//  UserDefaultsKeys.swift
//  WorkingHours
//
//  Created by Yordan Dimitrov on 29.03.24.
//

import Foundation

protocol KeyValueStoring {
    func set<T: Encodable>(_ value: T, forKey key: String) throws
    func get<T: Decodable>(_ type: T.Type, forKey key: String, _ defaultData: T) throws -> T
}

class UserDefaultsStore: KeyValueStoring {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func set<T>(_ value: T, forKey key: String) throws where T : Encodable {
        let encodeData = try encoder.encode(value)
        defaults.set(encodeData, forKey: key)
    }
    
    func get<T>(_ type: T.Type, forKey key: String, _ defaultData: T) throws -> T where T : Decodable {
        guard let data = defaults.data(forKey: key) else { return defaultData}
        return try decoder.decode(type, from: data)
    }
    
    func removeValue(keyValue: String) {
        defaults.removeObject(forKey: keyValue)
    }
    
}
