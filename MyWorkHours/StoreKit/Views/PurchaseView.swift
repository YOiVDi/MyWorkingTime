//
//  StoreView.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 03.10.25.
//

import SwiftUI
import StoreKit

struct PurchaseView: View {
    
    @ObservedObject var viewModel: PurchaseViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),   // deep navy
                    Color(red: 0.18, green: 0.00, blue: 0.35)    // rich purple
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
                VStack(spacing: 10) {
                    // MARK: - Title
                    VStack {
                        Image(systemName: "crown")
                            .font(.system(size: 50)).bold()
                            .foregroundStyle(.white)
                        Group {
                            Text("Go Premium to Unlock More Power")
                        }
                        .font(.largeTitle).bold()
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    }
                    
                    // MARK: - Information
                    VStack(spacing: 5) {
                        FeatureView(message: "Add a second job or shift.")
                        FeatureView(message: "View days automatically grouped by month.")
                        FeatureView(message: "See visual indicators when work hours are above or below your target.")
//                        FeatureView(message: "Download a specific day as a PDF file.")
                    }
                    .padding(.horizontal)
                    .padding(.top, 50)
                    // MARK: - Buttons
                    VStack(spacing: 10) {
                        ForEach(viewModel.products) { product in
                                Button {
                                    withAnimation(.none) {
                                        viewModel.buy(product)
                                    }
                                } label: {
                                    HStack {
                                        Text("\(product.displayPrice) - \(product.displayName)")
                                            .font(product.displayName == "Yearly" ? .system(size: 25) : .system(size: 20)).bold()
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 60)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.horizontal)
                            }
                            if product.displayName == "Yearly" {
                                Text("Get 2 months free with a yearly plan!")
                                    .font(.system(size: 20))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
    }
}

#Preview {
    PurchaseView(viewModel: PurchaseViewModel(userStatusManager: UserStatusManager()))
}
