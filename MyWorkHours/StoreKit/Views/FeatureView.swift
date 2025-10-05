//
//  Feature.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 05.10.25.
//

import SwiftUI

struct FeatureView: View {
    var message: LocalizedStringKey
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "checkmark.seal")
                    .font(.system(size: 30)).bold()
                    .foregroundStyle(.blue)
                Text(message)
                    .multilineTextAlignment(.center)
                    .font(.title2).bold()
                    .foregroundStyle(.white)
            }
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .foregroundStyle(.white)
        }
        .frame(width: 300)
    }
}

#Preview {
    FeatureView(message: "Test Message")
}
