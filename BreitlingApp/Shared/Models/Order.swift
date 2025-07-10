//
//  Order.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/10/25.
//

//
//  Order.swift
//  BreitlingApp
//
//  Order model for purchase history and tracking
//  Supports luxury ecommerce purchase journey
//

import Foundation

struct Order: Identifiable, Codable {
    let id: String
    let orderNumber: String
    let userId: String
    let items: [OrderItem]
    let orderDate: Date
    let status: OrderStatus
    let payment: PaymentInfo
    let shipping: ShippingInfo
    let billing: BillingAddress
    let customerNotes: String?
    let specialInstructions: String?
    let giftMessage: String?
    let isGift: Bool
    let storeId: String? // If purchased in-store
    let salesAssociate: String? // Store associate name
    
    // Computed properties
    var subtotal: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var taxAmount: Double {
        subtotal * (payment.taxRate / 100)
    }
    
    var shippingCost: Double {
        shipping.cost
    }
    
    var totalAmount: Double {
        subtotal + taxAmount + shippingCost
    }
    
    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = payment.currency
        return formatter.string(from: NSNumber(value: totalAmount)) ?? "\(payment.currency) \(totalAmount)"
    }
    
    var canCancel: Bool {
        status == .pending || status == .confirmed
    }
    
    var canReturn: Bool {
        (status == .delivered || status == .completed) && daysSinceDelivery <= 30
    }
    
    var daysSinceOrder: Int {
        Calendar.current.dateComponents([.day], from: orderDate, to: Date()).day ?? 0
    }
    
    var daysSinceDelivery: Int {
        guard let deliveryDate = shipping.actualDeliveryDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: deliveryDate, to: Date()).day ?? 0
    }
    
    var estimatedDeliveryDate: Date? {
        shipping.estimatedDeliveryDate
    }
    
    var isPremiumOrder: Bool {
        totalAmount >= 10000 // Orders over $10k get premium treatment
    }
}

struct OrderItem: Identifiable, Codable {
    let id: String
    let productId: String
    let productName: String
    let collectionName: String
    let sku: String
    let quantity: Int
    let unitPrice: Double
    let currency: String
    let customizations: [ProductCustomization]?
    let engraving: EngravingDetails?
    let warranty: WarrantyInfo
    
    var totalPrice: Double {
        Double(quantity) * unitPrice
    }
    
    var formattedUnitPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: unitPrice)) ?? "\(currency) \(unitPrice)"
    }
    
    var hasCustomizations: Bool {
        !(customizations?.isEmpty ?? true) || engraving != nil
    }
}

struct ProductCustomization: Codable {
    let type: CustomizationType
    let value: String
    let additionalCost: Double
}

enum CustomizationType: String, Codable, CaseIterable {
    case dial = "dial"
    case strap = "strap"
    case bezel = "bezel"
    case caseMaterial = "case_material"
    case movement = "movement"
    
    var displayName: String {
        switch self {
        case .dial:
            return "Dial"
        case .strap:
            return "Strap/Bracelet"
        case .bezel:
            return "Bezel"
        case .caseMaterial:
            return "Case Material"
        case .movement:
            return "Movement"
        }
    }
}

struct EngravingDetails: Codable {
    let text: String
    let location: EngravingLocation
    let font: String
    let cost: Double
}

enum EngravingLocation: String, Codable, CaseIterable {
    case caseback = "caseback"
    case clasp = "clasp"
    case rotor = "rotor"
    
    var displayName: String {
        switch self {
        case .caseback:
            return "Case Back"
        case .clasp:
            return "Bracelet Clasp"
        case .rotor:
            return "Movement Rotor"
        }
    }
}

struct WarrantyInfo: Codable {
    let duration: Int // Years
    let type: WarrantyType
    let registrationDate: Date?
    let warrantyNumber: String?
    let isRegistered: Bool
}

enum WarrantyType: String, Codable {
    case standard = "standard"
    case extended = "extended"
    case premium = "premium"
    
    var displayName: String {
        switch self {
        case .standard:
            return "Standard Warranty"
        case .extended:
            return "Extended Warranty"
        case .premium:
            return "Premium Care Package"
        }
    }
}

enum OrderStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case confirmed = "confirmed"
    case processing = "processing"
    case shipped = "shipped"
    case delivered = "delivered"
    case completed = "completed"
    case cancelled = "cancelled"
    case returned = "returned"
    case refunded = "refunded"
    
    var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .confirmed:
            return "Confirmed"
        case .processing:
            return "Processing"
        case .shipped:
            return "Shipped"
        case .delivered:
            return "Delivered"
        case .completed:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        case .returned:
            return "Returned"
        case .refunded:
            return "Refunded"
        }
    }
    
    var color: String {
        switch self {
        case .pending, .confirmed:
            return "orange"
        case .processing, .shipped:
            return "blue"
        case .delivered, .completed:
            return "green"
        case .cancelled, .returned, .refunded:
            return "red"
        }
    }
    
    var iconName: String {
        switch self {
        case .pending:
            return "clock"
        case .confirmed:
            return "checkmark.circle"
        case .processing:
            return "gearshape"
        case .shipped:
            return "shippingbox"
        case .delivered:
            return "house"
        case .completed:
            return "checkmark.circle.fill"
        case .cancelled:
            return "xmark.circle"
        case .returned:
            return "return"
        case .refunded:
            return "creditcard"
        }
    }
}

struct PaymentInfo: Codable {
    let method: PaymentMethod
    let currency: String
    let taxRate: Double // Percentage
    let transactionId: String?
    let paymentDate: Date?
    let lastFourDigits: String? // For credit cards
    let cardType: String? // Visa, Mastercard, etc.
}

enum PaymentMethod: String, Codable, CaseIterable {
    case creditCard = "credit_card"
    case applePay = "apple_pay"
    case wire = "wire_transfer"
    case financing = "financing"
    case storeCredit = "store_credit"
    
    var displayName: String {
        switch self {
        case .creditCard:
            return "Credit Card"
        case .applePay:
            return "Apple Pay"
        case .wire:
            return "Wire Transfer"
        case .financing:
            return "Financing"
        case .storeCredit:
            return "Store Credit"
        }
    }
}

struct ShippingInfo: Codable {
    let method: ShippingMethod
    let cost: Double
    let carrier: String
    let trackingNumber: String?
    let estimatedDeliveryDate: Date?
    let actualDeliveryDate: Date?
    let shippingAddress: ShippingAddress
    let requiresSignature: Bool
    let isInsured: Bool
    let insuranceValue: Double?
}

enum ShippingMethod: String, Codable, CaseIterable {
    case standard = "standard"
    case expedited = "expedited"
    case overnight = "overnight"
    case whiteGlove = "white_glove"
    case storePickup = "store_pickup"
    
    var displayName: String {
        switch self {
        case .standard:
            return "Standard Shipping"
        case .expedited:
            return "Expedited Shipping"
        case .overnight:
            return "Overnight"
        case .whiteGlove:
            return "White Glove Delivery"
        case .storePickup:
            return "Store Pickup"
        }
    }
    
    var estimatedDays: Int {
        switch self {
        case .standard:
            return 7
        case .expedited:
            return 3
        case .overnight:
            return 1
        case .whiteGlove:
            return 5
        case .storePickup:
            return 0
        }
    }
}

struct ShippingAddress: Codable {
    let firstName: String
    let lastName: String
    let company: String?
    let street1: String
    let street2: String?
    let city: String
    let state: String
    let zipCode: String
    let country: String
    let phone: String?
    
    var formattedAddress: String {
        var address = "\(street1)"
        if let street2 = street2, !street2.isEmpty {
            address += "\n\(street2)"
        }
        address += "\n\(city), \(state) \(zipCode)"
        address += "\n\(country)"
        return address
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

struct BillingAddress: Codable {
    let firstName: String
    let lastName: String
    let company: String?
    let street1: String
    let street2: String?
    let city: String
    let state: String
    let zipCode: String
    let country: String
    
    var formattedAddress: String {
        var address = "\(street1)"
        if let street2 = street2, !street2.isEmpty {
            address += "\n\(street2)"
        }
        address += "\n\(city), \(state) \(zipCode)"
        address += "\n\(country)"
        return address
    }
}

// MARK: - Mock Data for Development
extension Order {
    static let mockOrders: [Order] = [
        Order(
            id: "order-12345",
            orderNumber: "BR-2024-001234",
            userId: "user-12345",
            items: [OrderItem.mockOrderItem],
            orderDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            status: .shipped,
            payment: PaymentInfo(
                method: .creditCard,
                currency: "USD",
                taxRate: 8.25,
                transactionId: "txn_1234567890",
                paymentDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
                lastFourDigits: "4242",
                cardType: "Visa"
            ),
            shipping: ShippingInfo(
                method: .expedited,
                cost: 50.00,
                carrier: "FedEx",
                trackingNumber: "1Z999AA1234567890",
                estimatedDeliveryDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
                actualDeliveryDate: nil,
                shippingAddress: ShippingAddress.mockAddress,
                requiresSignature: true,
                isInsured: true,
                insuranceValue: 9000.00
            ),
            billing: BillingAddress.mockAddress,
            customerNotes: "Please handle with care",
            specialInstructions: "Leave with concierge if not home",
            giftMessage: nil,
            isGift: false,
            storeId: nil,
            salesAssociate: nil
        ),
        Order(
            id: "order-12346",
            orderNumber: "BR-2024-001235",
            userId: "user-12345",
            items: [OrderItem.mockCustomOrderItem],
            orderDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
            status: .completed,
            payment: PaymentInfo(
                method: .applePay,
                currency: "USD",
                taxRate: 8.25,
                transactionId: "ap_9876543210",
                paymentDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()),
                lastFourDigits: nil,
                cardType: nil
            ),
            shipping: ShippingInfo(
                method: .whiteGlove,
                cost: 250.00,
                carrier: "White Glove Service",
                trackingNumber: "WG-234567890",
                estimatedDeliveryDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())?.addingTimeInterval(7 * 24 * 60 * 60),
                actualDeliveryDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())?.addingTimeInterval(6 * 24 * 60 * 60),
                shippingAddress: ShippingAddress.mockAddress,
                requiresSignature: true,
                isInsured: true,
                insuranceValue: 15000.00
            ),
            billing: BillingAddress.mockAddress,
            customerNotes: nil,
            specialInstructions: "White glove delivery preferred",
            giftMessage: "Happy Anniversary! Love, Sarah",
            isGift: true,
            storeId: "store-ny-madison",
            salesAssociate: "Michael Thompson"
        )
    ]
}

extension OrderItem {
    static let mockOrderItem = OrderItem(
        id: "item-001",
        productId: "navitimer-b01-chronograph-43",
        productName: "Navitimer B01 Chronograph 43",
        collectionName: "Navitimer",
        sku: "AB0121211B1P1",
        quantity: 1,
        unitPrice: 8950.00,
        currency: "USD",
        customizations: nil,
        engraving: nil,
        warranty: WarrantyInfo(
            duration: 2,
            type: .standard,
            registrationDate: nil,
            warrantyNumber: nil,
            isRegistered: false
        )
    )
    
    static let mockCustomOrderItem = OrderItem(
        id: "item-002",
        productId: "chronomat-b01-42-custom",
        productName: "Chronomat B01 42 Custom",
        collectionName: "Chronomat",
        sku: "AB0134101C1A1-CUSTOM",
        quantity: 1,
        unitPrice: 12950.00,
        currency: "USD",
        customizations: [
            ProductCustomization(type: .dial, value: "Blue Dial", additionalCost: 500.00),
            ProductCustomization(type: .strap, value: "Gold Bracelet", additionalCost: 2000.00)
        ],
        engraving: EngravingDetails(
            text: "J.S. • 25.06.2024",
            location: .caseback,
            font: "Classic Script",
            cost: 150.00
        ),
        warranty: WarrantyInfo(
            duration: 5,
            type: .premium,
            registrationDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()),
            warrantyNumber: "WTY-2024-789456",
            isRegistered: true
        )
    )
}

extension ShippingAddress {
    static let mockAddress = ShippingAddress(
        firstName: "John",
        lastName: "Smith",
        company: nil,
        street1: "123 Park Avenue",
        street2: "Apt 4B",
        city: "New York",
        state: "NY",
        zipCode: "10016",
        country: "United States",
        phone: "+1 (555) 123-4567"
    )
}

extension BillingAddress {
    static let mockAddress = BillingAddress(
        firstName: "John",
        lastName: "Smith",
        company: nil,
        street1: "123 Park Avenue",
        street2: "Apt 4B",
        city: "New York",
        state: "NY",
        zipCode: "10016",
        country: "United States"
    )
}
