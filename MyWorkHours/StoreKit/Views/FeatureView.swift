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
                        .frame(width: 26, alignment: .top)
                    Spacer()
                    Text(message)
                        .multilineTextAlignment(.center)
                        .font(.title3 ).bold()
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .foregroundStyle(.white)
        }
    }
}

#Preview {
    FeatureView(message: "Test Message")
}
