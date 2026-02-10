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
    
    private let trialMessage: String = """
Try all premium features free for 3 days. After the trial ends, your subscription will 
automatically renew unless canceled at least 24 hours before the end of the current 
period. Payment will be charged to your Apple ID at confirmation of purchase. You can 
manage or cancel your subscription at any time in your Apple ID settings.
"""
    
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
                    .padding(.top, 30)
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
                                            .font(product.id == "com.myworkhours.premiumaccess.yearlytwo" ? .system(size: 25) : .system(size: 20)).bold()
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 60)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.horizontal)
                            }
                            if product.id == "com.myworkhours.premiumaccess.yearlytwo" {
                                Text("Save 2 months with the yearly plan!")
                                    .font(.system(size: 20))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Button("Restore Purchase") {
                            viewModel.restorePurchases()
                        }
                        Text(trialMessage)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.7))
                            .font(.system(size: 15))
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.85)
                            .padding(.horizontal)
                    }
                    // MARK: - Legal
                    VStack {
                        // MARK: - Legal
                        Link("Privacy Policy", destination: URL(string: "https://www.yoiddev.com/workhours-privacy-policy")!)
                        Link("Terms of Service", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/?utm_source=chatgpt.com")!)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
    }
}

#Preview {
    PurchaseView(viewModel: PurchaseViewModel(userStatusStore: UserStatusStore(userDefaultsStore: UserDefaultsStore())))
}
