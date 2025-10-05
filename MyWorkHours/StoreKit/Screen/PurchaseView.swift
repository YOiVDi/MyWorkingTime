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
                LinearGradient(colors: [.blue, .red.opacity(0.8)], startPoint: .top, endPoint: .center)
                VStack(spacing: 10) {
                    // MARK: - Title
                    VStack {
                        Image(systemName: "crown")
                            .font(.system(size: 50)).bold()
                            .foregroundStyle(.white)
                        Group {
                            Text("Access to Premium Features")
                        }
                        .font(.largeTitle).bold()
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    }
                    
                    // MARK: - Information
                    VStack(spacing: 5) {
                        FeatureView(message: "Add a second work/task.")
                        FeatureView(message: "Organize days by month and year via section.")
                        FeatureView(message: "Download a specific day as a PDF file.")
                    }
                    .padding(.horizontal)
                    .padding(.top, 50)
                    // MARK: - Buttons
                    VStack(spacing: 10) {
                        ForEach(viewModel.products) { product in
                                Button {
                                    viewModel.buy(product)
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
                                Text("By Subscribing for 1 year you will get two months free.")
                                    .font(.system(size: 20))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ignoresSafeArea()
    }
    
    init(userStatusManager: UserStatusManager) {
        _viewModel = ObservedObject(wrappedValue: PurchaseViewModel(userStatusManager: userStatusManager))
    }

}

#Preview {
    PurchaseView(userStatusManager: UserStatusManager())
}
