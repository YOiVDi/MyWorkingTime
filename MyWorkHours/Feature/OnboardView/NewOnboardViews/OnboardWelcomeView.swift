//
//  OnboardWelcomeView.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 27.12.25.
//

import SwiftUI

struct OnboardWelcomeView: View {
    var body: some View {
        VStack(spacing: 16) {
//                Text("Your Work Hours")
//                    .font(.title.bold())
//                    .frame(maxWidth: .infinity, alignment: .center)
                Image("OnbordingWelcome")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
            Text("Set your default shift once. We’ll calculate your work time automatically.")
                .multilineTextAlignment(.center)
                .font(.title.bold())
                .foregroundStyle(.primary)
                .padding(.horizontal)
                .padding(.top, 50)
            Text("You can change this later in Settings.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            Spacer()
        }
        .padding(.top, 100)
    }
}

#Preview {
    OnboardWelcomeView()
}
