//
//  Store.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/10/25.
//

//
//  Store.swift
//  BreitlingApp
//
//  Boutique/Store model for store locator functionality
//  Supports MapKit integration and appointment booking
//

import Foundation
import CoreLocation

struct Store: Identifiable, Codable {
    let id: String
    let name: String
    let storeType: StoreType
    let address: StoreAddress
    let contact: StoreContact
    let hours: StoreHours
    let services: [StoreService]
    let coordinate: StoreCoordinate
    let images: [String]
    let description: String
    let specialties: [String]
    let languages: [String]
    let isAppointmentRequired: Bool
    let hasParking: Bool
    let accessibility: AccessibilityFeatures
    
    // Computed properties
    var formattedAddress: String {
        "\(address.street), \(address.city), \(address.state) \(address.zipCode)"
    }
    
    var isOpen: Bool {
        let now = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now)
        let currentTime = calendar.dateComponents([.hour, .minute], from: now)
        
        guard let todayHours = hours.hoursForWeekday(weekday),
              let openTime = todayHours.openTime,
              let closeTime = todayHours.closeTime else {
            return false
        }
        
        let currentMinutes = (currentTime.hour ?? 0) * 60 + (currentTime.minute ?? 0)
        let openMinutes = openTime.hour * 60 + openTime.minute
        let closeMinutes = closeTime.hour * 60 + closeTime.minute
        
        return currentMinutes >= openMinutes && currentMinutes < closeMinutes
    }
    
    var distanceFromUser: CLLocationDistance? {
        // Will be calculated when user location is available
        nil
    }
    
    // Convert to CLLocation for MapKit
    var location: CLLocation {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

struct StoreAddress: Codable {
    let street: String
    let city: String
    let state: String
    let zipCode: String
    let country: String
    let countryCode: String
}

struct StoreContact: Codable {
    let phone: String
    let email: String
    let website: String?
    let socialMedia: SocialMediaLinks?
}

struct SocialMediaLinks: Codable {
    let instagram: String?
    let facebook: String?
    let twitter: String?
}

struct StoreHours: Codable {
    let monday: DayHours?
    let tuesday: DayHours?
    let wednesday: DayHours?
    let thursday: DayHours?
    let friday: DayHours?
    let saturday: DayHours?
    let sunday: DayHours?
    let holidays: String?
    
    func hoursForWeekday(_ weekday: Int) -> DayHours? {
        switch weekday {
        case 1: return sunday
        case 2: return monday
        case 3: return tuesday
        case 4: return wednesday
        case 5: return thursday
        case 6: return friday
        case 7: return saturday
        default: return nil
        }
    }
    
    var weekdayHours: [DayHours?] {
        [monday, tuesday, wednesday, thursday, friday, saturday, sunday]
    }
}

struct DayHours: Codable {
    let openTime: TimeComponents?
    let closeTime: TimeComponents?
    let isClosed: Bool
    
    var displayText: String {
        if isClosed {
            return "Closed"
        }
        
        guard let open = openTime, let close = closeTime else {
            return "Hours not available"
        }
        
        return "\(open.displayTime) - \(close.displayTime)"
    }
}

struct TimeComponents: Codable {
    let hour: Int
    let minute: Int
    
    var displayTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let calendar = Calendar.current
        let date = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
        
        return formatter.string(from: date)
    }
}

struct StoreCoordinate: Codable {
    let latitude: Double
    let longitude: Double
}

enum StoreType: String, Codable, CaseIterable {
    case flagship = "flagship"
    case boutique = "boutique"
    case authorizedDealer = "authorized_dealer"
    case serviceCenter = "service_center"
    case popup = "popup"
    
    var displayName: String {
        switch self {
        case .flagship:
            return "Flagship Store"
        case .boutique:
            return "Breitling Boutique"
        case .authorizedDealer:
            return "Authorized Dealer"
        case .serviceCenter:
            return "Service Center"
        case .popup:
            return "Pop-up Store"
        }
    }
    
    var priority: Int {
        switch self {
        case .flagship:
            return 1
        case .boutique:
            return 2
        case .serviceCenter:
            return 3
        case .authorizedDealer:
            return 4
        case .popup:
            return 5
        }
    }
}

enum StoreService: String, Codable, CaseIterable {
    case watchSales = "watch_sales"
    case repairService = "repair_service"
    case customization = "customization"
    case appointments = "appointments"
    case certification = "certification"
    case tradeIn = "trade_in"
    case personalShopping = "personal_shopping"
    case watchmaking = "watchmaking"
    case engraving = "engraving"
    case batteryReplacement = "battery_replacement"
    
    var displayName: String {
        switch self {
        case .watchSales:
            return "Watch Sales"
        case .repairService:
            return "Repair & Service"
        case .customization:
            return "Watch Customization"
        case .appointments:
            return "Private Appointments"
        case .certification:
            return "Authentication & Certification"
        case .tradeIn:
            return "Trade-in Program"
        case .personalShopping:
            return "Personal Shopping"
        case .watchmaking:
            return "Watchmaking Services"
        case .engraving:
            return "Engraving Services"
        case .batteryReplacement:
            return "Battery Replacement"
        }
    }
    
    var iconName: String {
        switch self {
        case .watchSales:
            return "watch"
        case .repairService:
            return "wrench.and.screwdriver"
        case .customization:
            return "slider.horizontal.3"
        case .appointments:
            return "calendar"
        case .certification:
            return "checkmark.seal"
        case .tradeIn:
            return "arrow.triangle.2.circlepath"
        case .personalShopping:
            return "person.badge.plus"
        case .watchmaking:
            return "gearshape.2"
        case .engraving:
            return "pencil.and.outline"
        case .batteryReplacement:
            return "battery.100"
        }
    }
}

struct AccessibilityFeatures: Codable {
    let wheelchairAccessible: Bool
    let hearingAssistance: Bool
    let visualAssistance: Bool
    let elevatorAccess: Bool
    let accessibleParking: Bool
}

// MARK: - Mock Data for Development
extension Store {
    static let mockStores: [Store] = [
        Store(
            id: "store-ny-madison",
            name: "Breitling Madison Avenue",
            storeType: .flagship,
            address: StoreAddress(
                street: "645 Madison Avenue",
                city: "New York",
                state: "NY",
                zipCode: "10022",
                country: "United States",
                countryCode: "US"
            ),
            contact: StoreContact(
                phone: "+1 (212) 308-0600",
                email: "madison@breitling.com",
                website: "https://www.breitling.com/us-en/stores/new-york-madison/",
                socialMedia: SocialMediaLinks(
                    instagram: "@breitling_madison",
                    facebook: nil,
                    twitter: nil
                )
            ),
            hours: StoreHours(
                monday: DayHours(openTime: TimeComponents(hour: 10, minute: 0), closeTime: TimeComponents(hour: 19, minute: 0), isClosed: false),
                tuesday: DayHours(openTime: TimeComponents(hour: 10, minute: 0), closeTime: TimeComponents(hour: 19, minute: 0), isClosed: false),
                wednesday: DayHours(openTime: TimeComponents(hour: 10, minute: 0), closeTime: TimeComponents(hour: 19, minute: 0), isClosed: false),
                thursday: DayHours(openTime: TimeComponents(hour: 10, minute: 0), closeTime: TimeComponents(hour: 19, minute: 0), isClosed: false),
                friday: DayHours(openTime: TimeComponents(hour: 10, minute: 0), closeTime: TimeComponents(hour: 19, minute: 0), isClosed: false),
                saturday: DayHours(openTime: TimeComponents(hour: 10, minute: 0), closeTime: TimeComponents(hour: 18, minute: 0), isClosed: false),
                sunday: DayHours(openTime: TimeComponents(hour: 12, minute: 0), closeTime: TimeComponents(hour: 17, minute: 0), isClosed: false),
                holidays: "Limited hours on major holidays"
            ),
            services: [.watchSales, .repairService, .customization, .appointments, .certification, .personalShopping, .engraving],
            coordinate: StoreCoordinate(latitude: 40.7614, longitude: -73.9733),
            images: ["madison-store-exterior", "madison-store-interior", "madison-store-display"],
            description: "Our flagship Manhattan boutique offers the complete Breitling experience with expert watchmakers, personalized service, and exclusive timepieces.",
            specialties: ["Limited Edition Collections", "Manufacture Movements", "Heritage Pieces", "Custom Engravings"],
            languages: ["English", "Spanish", "French", "Italian"],
            isAppointmentRequired: false,
            hasParking: false,
            accessibility: AccessibilityFeatures(
                wheelchairAccessible: true,
                hearingAssistance: true,
                visualAssistance: false,
                elevatorAccess: true,
                accessibleParking: false
            )
        ),
        Store(
            id: "store-ca-beverly-hills",
            name: "Breitling Beverly Hills",
            storeType: .boutique,
            address: StoreAddress(
                street: "9700 Wilshire Boulevard",
                city: "Beverly Hills",
                state: "CA",
                zipCode: "90212",
                country: "United States",
                countryCode: "US"
            ),
            contact: StoreContact(
                phone: "+1 (310) 248-2141",
                email: "beverlyhills@breitling.com",
                website: "https://www.breitling.com/us-en/stores/beverly-hills/",
                socialMedia: nil
            ),
            hours: StoreHours(
                monday: DayHours(openTime: TimeComponents(hour: 10, minute: 0), closeTime: TimeComponents(hour: 20, minute: 0), isClosed: false),
                tuesday: DayHours(openTime: TimeComponents(hour: 10, minute: 0), closeTime: TimeComponents(hour: 20, minute: 0), isClosed: false),
                wednesday: DayHours(openTime: TimeComponents(hour: 10, minute: 0), closeTime: TimeComponents(hour: 20, minute: 0), isClosed: false),
                thursday: DayHours(openTime: TimeComponents(hour: 10, minute: 0), closeTime: TimeComponents(hour: 20, minute: 0), isClosed: false),
                friday: DayHours(openTime: TimeComponents(hour: 10, minute: 0), closeTime: TimeComponents(hour: 20, minute: 0), isClosed: false),
                saturday: DayHours(openTime: TimeComponents(hour: 10, minute: 0), closeTime: TimeComponents(hour: 19, minute: 0), isClosed: false),
                sunday: DayHours(openTime: TimeComponents(hour: 12, minute: 0), closeTime: TimeComponents(hour: 18, minute: 0), isClosed: false),
                holidays: nil
            ),
            services: [.watchSales, .repairService, .appointments, .certification, .personalShopping],
            coordinate: StoreCoordinate(latitude: 34.0669, longitude: -118.3956),
            images: ["beverly-hills-exterior", "beverly-hills-interior"],
            description: "Located in the heart of Beverly Hills, our boutique caters to discerning clients seeking exceptional timepieces and personalized service.",
            specialties: ["Celebrity Clientele", "Exclusive West Coast Releases", "VIP Services"],
            languages: ["English", "Spanish"],
            isAppointmentRequired: true,
            hasParking: true,
            accessibility: AccessibilityFeatures(
                wheelchairAccessible: true,
                hearingAssistance: false,
                visualAssistance: false,
                elevatorAccess: false,
                accessibleParking: true
            )
        ),
        Store(
            id: "store-fl-miami",
            name: "Breitling Miami Design District",
            storeType: .boutique,
            address: StoreAddress(
                street: "140 NE 39th Street",
                city: "Miami",
                state: "FL",
                zipCode: "33137",
                country: "United States",
                countryCode: "US"
            ),
            contact: StoreContact(
                phone: "+1 (305) 576-9819",
                email: "miami@breitling.com",
                website: "https://www.breitling.com/us-en/stores/miami/",
                socialMedia: SocialMediaLinks(
                    instagram: "@breitling_miami",
                    facebook: "BreitlingMiami",
                    twitter: nil
                )
            ),
            hours: StoreHours(
                monday: DayHours(openTime: TimeComponents(hour: 11, minute: 0), closeTime: TimeComponents(hour: 19, minute: 0), isClosed: false),
                tuesday: DayHours(openTime: TimeComponents(hour: 11, minute: 0), closeTime: TimeComponents(hour: 19, minute: 0), isClosed: false),
                wednesday: DayHours(openTime: TimeComponents(hour: 11, minute: 0), closeTime: TimeComponents(hour: 19, minute: 0), isClosed: false),
                thursday: DayHours(openTime: TimeComponents(hour: 11, minute: 0), closeTime: TimeComponents(hour: 19, minute: 0), isClosed: false),
                friday: DayHours(openTime: TimeComponents(hour: 11, minute: 0), closeTime: TimeComponents(hour: 20, minute: 0), isClosed: false),
                saturday: DayHours(openTime: TimeComponents(hour: 11, minute: 0), closeTime: TimeComponents(hour: 20, minute: 0), isClosed: false),
                sunday: DayHours(openTime: TimeComponents(hour: 12, minute: 0), closeTime: TimeComponents(hour: 18, minute: 0), isClosed: false),
                holidays: "Closed on major holidays"
            ),
            services: [.watchSales, .appointments, .certification, .tradeIn],
            coordinate: StoreCoordinate(latitude: 25.8092, longitude: -80.1951),
            images: ["miami-store-front", "miami-display"],
            description: "Our Miami boutique in the vibrant Design District showcases Breitling's ocean-inspired collections in a contemporary setting.",
            specialties: ["Ocean Collection Focus", "Diving Watches", "Yacht Timer Collection"],
            languages: ["English", "Spanish", "Portuguese"],
            isAppointmentRequired: false,
            hasParking: true,
            accessibility: AccessibilityFeatures(
                wheelchairAccessible: true,
                hearingAssistance: false,
                visualAssistance: false,
                elevatorAccess: false,
                accessibleParking: true
            )
        ),
        Store(
            id: "store-tx-dallas-service",
            name: "Breitling Service Center Dallas",
            storeType: .serviceCenter,
            address: StoreAddress(
                street: "17350 Dallas Parkway",
                city: "Dallas",
                state: "TX",
                zipCode: "75287",
                country: "United States",
                countryCode: "US"
            ),
            contact: StoreContact(
                phone: "+1 (972) 732-4200",
                email: "service-dallas@breitling.com",
                website: nil,
                socialMedia: nil
            ),
            hours: StoreHours(
                monday: DayHours(openTime: TimeComponents(hour: 9, minute: 0), closeTime: TimeComponents(hour: 17, minute: 0), isClosed: false),
                tuesday: DayHours(openTime: TimeComponents(hour: 9, minute: 0), closeTime: TimeComponents(hour: 17, minute: 0), isClosed: false),
                wednesday: DayHours(openTime: TimeComponents(hour: 9, minute: 0), closeTime: TimeComponents(hour: 17, minute: 0), isClosed: false),
                thursday: DayHours(openTime: TimeComponents(hour: 9, minute: 0), closeTime: TimeComponents(hour: 17, minute: 0), isClosed: false),
                friday: DayHours(openTime: TimeComponents(hour: 9, minute: 0), closeTime: TimeComponents(hour: 17, minute: 0), isClosed: false),
                saturday: DayHours(openTime: nil, closeTime: nil, isClosed: true),
                sunday: DayHours(openTime: nil, closeTime: nil, isClosed: true),
                holidays: "Closed on weekends and holidays"
            ),
            services: [.repairService, .certification, .batteryReplacement, .watchmaking, .appointments],
            coordinate: StoreCoordinate(latitude: 32.9783, longitude: -96.8308),
            images: ["dallas-service-center"],
            description: "Our certified service center provides expert repair and maintenance services for all Breitling timepieces.",
            specialties: ["Manufacture Service", "Restoration", "Certified Repairs", "Warranty Service"],
            languages: ["English", "Spanish"],
            isAppointmentRequired: true,
            hasParking: true,
            accessibility: AccessibilityFeatures(
                wheelchairAccessible: true,
                hearingAssistance: false,
                visualAssistance: false,
                elevatorAccess: false,
                accessibleParking: true
            )
        )
    ]
    
    static let nearbyStore = mockStores[0] // Madison Avenue for testing
}
