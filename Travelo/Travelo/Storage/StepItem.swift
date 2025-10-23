//
//  StepItem.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 10/23/25.
//

import Foundation

struct StepItem: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let date: Date?
    let subtitle: String
    let order: Int
    let countryCode: String
    
    // Computed property for formatted date string
    var formattedDate: String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date).lowercased()
    }
}

// MARK: - Sample Data
extension StepItem {
    static let italySteps: [StepItem] = [
        StepItem(
            id: "codice-fiscale",
            title: "Codice Fiscale",
            date: Calendar.current.date(byAdding: .day, value: -10, to: Date()),
            subtitle: "Required for opening a bank account and signing rental contracts...",
            order: 10,
            countryCode: "IT"
        ),
        StepItem(
            id: "permesso-soggiorno",
            title: "Permesso di Soggiorno",
            date: Calendar.current.date(byAdding: .day, value: -4, to: Date()),
            subtitle: "Submit application within 8 days of arrival.",
            order: 20,
            countryCode: "IT"
        ),
        StepItem(
            id: "tessera-sanitaria",
            title: "Tessera Sanitaria",
            date: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
            subtitle: "Needed to access Italy's public healthcare system.",
            order: 30,
            countryCode: "IT"
        )
    ]
    
    static let mexicoSteps: [StepItem] = [
        StepItem(
            id: "curp-registration",
            title: "CURP Registration",
            date: Calendar.current.date(byAdding: .day, value: -7, to: Date()),
            subtitle: "Unique Population Registry Code required for most procedures...",
            order: 10,
            countryCode: "MX"
        ),
        StepItem(
            id: "temporal-resident-card",
            title: "Temporal Resident Card",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            subtitle: "Must be collected within 30 days of arrival.",
            order: 20,
            countryCode: "MX"
        ),
        StepItem(
            id: "rfc-tax-id",
            title: "RFC Tax ID",
            date: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
            subtitle: "Required for employment and opening bank accounts.",
            order: 30,
            countryCode: "MX"
        )
    ]
    
    static func steps(for countryCode: String) -> [StepItem] {
        switch countryCode {
        case "IT":
            return italySteps
        case "MX":
            return mexicoSteps
        default:
            return []
        }
    }
}

