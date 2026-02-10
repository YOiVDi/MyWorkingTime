//
//  Binding.swift
//  MyWorkTime
//
//  Created by Yordan Dimitrov on 13.05.24.
//

import SwiftUI

extension Binding where Value == Bool {
    
    init<T>(value: Binding<T?>) {
        self.init {
            value.wrappedValue != nil
        } set: { newValue in
            if !newValue  {
                value.wrappedValue = nil
            }
        }
    }
}
