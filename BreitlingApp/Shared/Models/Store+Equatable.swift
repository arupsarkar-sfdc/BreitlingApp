//
//  Store+Equatable.swift.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/11/25.
//

//
//  Store+Equatable.swift
//  BreitlingApp
//
//  Extension to make Store conform to Equatable for SwiftUI onChange
//

import Foundation

extension Store: Equatable {
    static func == (lhs: Store, rhs: Store) -> Bool {
        lhs.id == rhs.id
    }
}

extension StoreAddress: Equatable {
    static func == (lhs: StoreAddress, rhs: StoreAddress) -> Bool {
        lhs.street == rhs.street &&
        lhs.city == rhs.city &&
        lhs.state == rhs.state &&
        lhs.zipCode == rhs.zipCode
    }
}

extension StoreContact: Equatable {
    static func == (lhs: StoreContact, rhs: StoreContact) -> Bool {
        lhs.phone == rhs.phone && lhs.email == rhs.email
    }
}

extension SocialMediaLinks: Equatable {
    static func == (lhs: SocialMediaLinks, rhs: SocialMediaLinks) -> Bool {
        lhs.instagram == rhs.instagram &&
        lhs.facebook == rhs.facebook &&
        lhs.twitter == rhs.twitter
    }
}

extension StoreHours: Equatable {
    static func == (lhs: StoreHours, rhs: StoreHours) -> Bool {
        lhs.monday == rhs.monday &&
        lhs.tuesday == rhs.tuesday &&
        lhs.wednesday == rhs.wednesday &&
        lhs.thursday == rhs.thursday &&
        lhs.friday == rhs.friday &&
        lhs.saturday == rhs.saturday &&
        lhs.sunday == rhs.sunday
    }
}

extension DayHours: Equatable {
    static func == (lhs: DayHours, rhs: DayHours) -> Bool {
        lhs.openTime == rhs.openTime &&
        lhs.closeTime == rhs.closeTime &&
        lhs.isClosed == rhs.isClosed
    }
}

extension TimeComponents: Equatable {
    static func == (lhs: TimeComponents, rhs: TimeComponents) -> Bool {
        lhs.hour == rhs.hour && lhs.minute == rhs.minute
    }
}

extension StoreCoordinate: Equatable {
    static func == (lhs: StoreCoordinate, rhs: StoreCoordinate) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension AccessibilityFeatures: Equatable {
    static func == (lhs: AccessibilityFeatures, rhs: AccessibilityFeatures) -> Bool {
        lhs.wheelchairAccessible == rhs.wheelchairAccessible &&
        lhs.hearingAssistance == rhs.hearingAssistance &&
        lhs.visualAssistance == rhs.visualAssistance &&
        lhs.elevatorAccess == rhs.elevatorAccess &&
        lhs.accessibleParking == rhs.accessibleParking
    }
}
