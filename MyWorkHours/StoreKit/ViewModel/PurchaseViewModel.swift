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
    case subscriptionMonthly = "com.myworkhours.premiumaccess.monthly"
    case subscriptionYearly = "com.myworkhours.premiumaccess.yearly"
    case subscriptionTestperiod = "subscription_testperiod"
}

enum UserStatus: String {
    case basic = "basic"
    case subscribed = "subscribed"
}
@MainActor class PurchaseViewModel: ObservableObject {
    private var productsId: [String] = ProductID.allCases.map { $0.rawValue }
    @Published private(set) var products: [Product] = []
    @Published private(set) var userCurrentSubscription: Product?
    @Published private(set) var subscriptionExpirationDate: Date? = nil
    @Published private(set) var renewMessage: String = ""
    private var updates: Task<Void, Never>? = nil
    private let userStatusManager: UserStatusManager
    private var cancellables: Set<AnyCancellable> = []
    
    // Expose user current status
    var userStatus: UserStatus {
        userStatusManager.userStatus
    }
    
    init(userStatusManager: UserStatusManager) {
        self.userStatusManager = userStatusManager
        updates = newTransactionListenerTask()
        
        Task {
            await fetchProducts()
            await updateUserSubscriptionStatus()
            print("UserStatus after purchaseviewmodel init: \(userStatusManager.userStatus)")
        }
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
            await updateUserSubscriptionStatus() // refresh immediately after purchase
        }
    }
    
    
    func manageSubscription() async {
        do {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                try await AppStore.showManageSubscriptions(in: scene)
                await updateUserSubscriptionStatus()
            } else {
                // fallback if no active scene found
                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                    await UIApplication.shared.open(url)
                }
            }
        } catch {
            print("Failed to open Manage Subscriptions: \(error.localizedDescription)")
            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                await UIApplication.shared.open(url)
            }
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
                await self.handle(updatedTransaction: verificationResult)
            }
        }
    }
    
    // Handle purchase verification
    private func handle(updatedTransaction verificationResult: VerificationResult<Transaction>) async {
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
            print("Transaction is upgraded")
            return
        }
        
        // Subscription is active
        Task { @MainActor in
            self.userStatusManager.subscribed()
        }
    }
    
    // Updating user status base of current state of transaction
    private func updateUserSubscriptionStatus() async {
        var foundProduct: Product?
        var expiration: Date?
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard productsId.contains(transaction.productID) else { continue }
            
            // remember expiration date
            expiration = transaction.expirationDate
            
            
            // try to resolve the matching Product for display
            if let product = try? await Product.products(for: [transaction.productID]).first {
                foundProduct = product
                
                // Check for auto-renew
                if let statuses = try? await product.subscription?.status {
                    for status in statuses {
                        switch status.renewalInfo {
                        case .verified(let renewalInfo):
                            guard let expiration else { continue }
                            if renewalInfo.willAutoRenew {
                                renewMessage = "Next billing date: \(expiration.formatted(date: .abbreviated, time: .omitted))"
                            } else {
                                renewMessage = "Your subscription will expires on \(expiration.formatted(date: .abbreviated, time: .omitted)), and after that you will be no longer able to use premium features."
                            }
                            
                        case .unverified(_, let error):
                            print("⚠️ Unverified renewal info: \(error.localizedDescription)")
                        }
                    }
                }
            }
            
            
            
            // mark user as subscribed if still active
            if expiration == nil || expiration! > Date() {
                await MainActor.run { [weak self] in
                    self?.userStatusManager.subscribed()
                    self?.userCurrentSubscription = foundProduct
                    self?.subscriptionExpirationDate = expiration
                }
                return
            }
        }
        
        
        // nothing valid found → downgrade
        await MainActor.run { [weak self] in
            self?.userStatusManager.basic()
            self?.userCurrentSubscription = nil
            self?.subscriptionExpirationDate = nil
            print("no active subscriptions found")
        }
    }
    
    // Restore Purchase
    func restorePurchases() {
        Task {
            await updateUserSubscriptionStatus()
        }
    }
}

