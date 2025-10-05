//
//  PurchaseViewModel.swift
//  MyWorkHours
//
//  Created by Yordan Dimitrov on 03.10.25.
//

import Foundation
import StoreKit
import Combine

enum ProductID: String, CaseIterable {
    case subscriptionMonthly = "subscription_monthly"
    case subscriptionYearly = "subscription_yearly"
    case subscriptionTestperiod = "subscription_testperiod"
}

enum UserStatus: String {
    case basic = "basic"
    case subscribed = "subscribed"
}
@MainActor class PurchaseViewModel: ObservableObject {
    private var productsId: [String] = ProductID.allCases.map {$0.rawValue}
    @Published private(set) var products: [Product] = []
    private var updates: Task<Void, Never>? = nil
    private let userStatusManager: UserStatusManager
    
    init(userStatusManager: UserStatusManager) {
        self.userStatusManager = userStatusManager
        updates = newTransactionListenerTask()
        
        Task {
            await fetchProducts()
            await updateUserSubscriptionStatus()
        }
        print("UserStatus after purchaseviewmodel init: \(userStatusManager.userStatus)")
    }
    
    deinit {
        // Cancel the update handling task when you deinitialize the class.
        updates?.cancel()
        print("Deinitialized PurchaseViewModel")
    }
    
    // MARK: - Public Methods
    
    func buy(_ product: Product) {
        Task {
            await buyProduct(product)
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchProducts() async {
        do {
            let fetchedProducts = try await Product.products(for: productsId)
            products = fetchedProducts.sorted {$0.displayPrice < $1.displayPrice}
        } catch {
            print("Fetch purchaseable items failed: \(error.localizedDescription)")
        }
    }
    
    private func buyProduct(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                switch verificationResult {
                case .verified(let transaction):
                    await transaction.finish()
                    await MainActor.run { [weak self] in
                        self?.userStatusManager.subscribed()
                    }
                case .unverified(let transaction, let transactionError):
                    userStatusManager.basic()
                    await transaction.finish()
                    print("transaction is unverified: \(transactionError.localizedDescription)")
                    
                }
            case .pending:
                break
            case .userCancelled:
                break
                
            @unknown default:
                fatalError()
            }
            
        } catch {
            print("Buy Product failed: \(error.localizedDescription)")
        }
    }
    
    private func newTransactionListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                self.handle(updatedTransaction: verificationResult)
            }
        }
    }
    
    // Handle purchase verification
    private func handle(updatedTransaction verificationResult: VerificationResult<Transaction>) {
        guard case .verified(let transaction) = verificationResult else {
            return
        }
        
        defer { Task { await transaction.finish() } }
        
        if let revocationDate = transaction.revocationDate {
            // Subscription was refunded or revoked
            Task { @MainActor in
                self.userStatusManager.basic()
            }
            print("Subscription revoked at \(revocationDate)")
            return
        }
        
        if let expirationDate = transaction.expirationDate,
           expirationDate < Date() {
            // Subscription expired
            Task { @MainActor in
                self.userStatusManager.basic()
            }
            print("Subscription expired on \(expirationDate)")
            return
        }
        
        if transaction.isUpgraded {
            // Old transaction replaced by a higher-tier one
            return
        }
        
        // Subscription is active
        Task { @MainActor in
            self.userStatusManager.subscribed()
        }
    }
    
    // Updating user status base of current state of transaction
    private func updateUserSubscriptionStatus() async {
        // Get all current entitlements
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                // If any active transaction matches your subscription product IDs
                if productsId.contains(transaction.productID) {
                    if let expirationDate = transaction.expirationDate {
                        if expirationDate > Date() {
                            // Subscription is still active
                            await MainActor.run { [weak self] in
                                self?.userStatusManager.subscribed()
                            }
                            return
                        }
                    } else {
                        // Non-expiring entitlement (unlikely for subscription)
                        await MainActor.run { [weak self] in
                            self?.userStatusManager.subscribed()
                        }
                        return
                    }
                }
            }
        }
        
        // No active subscriptions found — downgrade user
        await MainActor.run {
            self.userStatusManager.basic()
            print("no active subscriptions found")
        }
    }
}

