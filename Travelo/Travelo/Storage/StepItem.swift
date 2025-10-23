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
    
    // Extended bureaucracy information
    let whatIs: String
    let whyIs: String
    let whereIs: String
    let whenIs: String
    let docRequired: [String]
    let usefulLinks: [String]
    
    // Computed property for formatted date string
    var formattedDate: String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date).lowercased()
    }
    
    // Step number based on order
    var stepNumber: Int {
        return (order / 10) // Since orders are 10, 20, 30, etc.
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
            countryCode: "IT",
            whatIs: "The Codice Fiscale is the Italian tax code - a 16-character alphanumeric code that uniquely identifies you in the Italian fiscal system. It's similar to a social security number and is essential for almost all official procedures in Italy.",
            whyIs: "You need the Codice Fiscale for virtually everything in Italy: opening a bank account, signing rental contracts, getting a SIM card, accessing healthcare, working legally, and any interaction with public administration.",
            whereIs: "You can get it at the local Agenzia delle Entrate office, Italian consulates abroad, or some authorized intermediaries like CAF (Centro di Assistenza Fiscale) offices.",
            whenIs: "Apply as soon as possible after arrival, ideally within the first week. Many other procedures depend on having this document.",
            docRequired: ["Valid Passport", "Visa or Entry Permit", "Proof of Address in Italy"],
            usefulLinks: ["Agenzia delle Entrate official page", "List of local offices", "Online application portal"]
        ),
        StepItem(
            id: "permesso-soggiorno",
            title: "Permesso di Soggiorno",
            date: Calendar.current.date(byAdding: .day, value: -4, to: Date()),
            subtitle: "Submit application within 8 days of arrival.",
            order: 20,
            countryCode: "IT",
            whatIs: "The Permesso di Soggiorno (residence permit) is an official document that allows non-EU citizens to legally stay in Italy for periods longer than 90 days.",
            whyIs: "It's legally required for all non-EU citizens staying in Italy for more than 90 days. Without it, you cannot legally remain in the country or access many services.",
            whereIs: "Apply at the local Questura (police headquarters) in your city. You'll need to book an appointment through the online system or by phone.",
            whenIs: "You must submit the application within 8 days of your arrival in Italy. The process can take several months, so start immediately.",
            docRequired: ["Valid Passport", "Visa", "University Acceptance Letter (if student)", "Proof of accommodation", "Financial guarantees"],
            usefulLinks: ["Questura appointment booking", "Official requirements list", "Student-specific guidelines"]
        ),
        StepItem(
            id: "tessera-sanitaria",
            title: "Tessera Sanitaria",
            date: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
            subtitle: "Needed to access Italy's public healthcare system.",
            order: 30,
            countryCode: "IT",
            whatIs: "The Tessera Sanitaria is Italy's health insurance card that provides access to the national healthcare system (SSN - Servizio Sanitario Nazionale).",
            whyIs: "Essential for accessing public healthcare services, getting prescriptions, visiting doctors, and receiving medical treatments at reduced costs.",
            whereIs: "Register at the local ASL (Azienda Sanitaria Locale) office in your area of residence.",
            whenIs: "Apply after obtaining your Codice Fiscale and residence registration, typically within the first month of arrival.",
            docRequired: ["Codice Fiscale", "Valid Passport", "Residence certificate", "European Health Insurance Card (if EU citizen)"],
            usefulLinks: ["ASL office locations", "Healthcare registration guide", "Emergency services information"]
        ),
        StepItem(
            id: "residenza",
            title: "Residenza",
            date: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
            subtitle: "Register your residence address with the municipality.",
            order: 40,
            countryCode: "IT",
            whatIs: "Residenza is the official registration of your address with the local municipality (comune). It establishes your legal residence in Italy.",
            whyIs: "Required for accessing many services including healthcare, voting rights, and various administrative procedures. Many documents require proof of residence.",
            whereIs: "Register at the Anagrafe office of your local municipality (Comune) where you live.",
            whenIs: "Should be done within a few weeks of settling in your accommodation and after obtaining other basic documents.",
            docRequired: ["Valid Passport", "Codice Fiscale", "Rental contract or proof of accommodation", "Declaration form"],
            usefulLinks: ["Municipality office locations", "Required forms download", "Residence registration guide"]
        ),
        StepItem(
            id: "bank-account",
            title: "Bank Account Setup",
            date: Calendar.current.date(byAdding: .day, value: 14, to: Date()),
            subtitle: "Open an Italian bank account for daily transactions.",
            order: 50,
            countryCode: "IT",
            whatIs: "Setting up an Italian bank account provides you with local banking services, debit cards, and the ability to receive payments and manage finances in Italy.",
            whyIs: "Essential for receiving salary payments, paying rent, setting up utilities, and managing day-to-day financial transactions in Italy.",
            whereIs: "Visit major Italian banks like Intesa Sanpaolo, UniCredit, BNL, or Banco BPM. Many have dedicated services for international customers.",
            whenIs: "Open an account after obtaining your Codice Fiscale and residence documentation, typically within the first month.",
            docRequired: ["Valid Passport", "Codice Fiscale", "Proof of residence", "Initial deposit (varies by bank)"],
            usefulLinks: ["Bank comparison guide", "International customer services", "Account types explanation"]
        )
    ]
    
    static let mexicoSteps: [StepItem] = [
        StepItem(
            id: "curp-registration",
            title: "CURP Registration",
            date: Calendar.current.date(byAdding: .day, value: -7, to: Date()),
            subtitle: "Unique Population Registry Code required for most procedures...",
            order: 10,
            countryCode: "MX",
            whatIs: "CURP (Clave Única de Registro de Población) is Mexico's unique population registry code - an 18-character identifier that serves as your primary identification in Mexican systems.",
            whyIs: "Required for virtually all official procedures in Mexico including employment, banking, healthcare, education, and government services.",
            whereIs: "Visit RENAPO offices, Mexican consulates, or authorized registration centers. Many procedures can also be done online.",
            whenIs: "Should be obtained as soon as possible, ideally within the first week of arrival or before if applying from abroad.",
            docRequired: ["Valid Passport", "Birth Certificate", "Proof of Address", "Immigration Documents"],
            usefulLinks: ["RENAPO official website", "Online CURP generation", "Office locations finder"]
        ),
        StepItem(
            id: "temporal-resident-card",
            title: "Temporal Resident Card",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            subtitle: "Must be collected within 30 days of arrival.",
            order: 20,
            countryCode: "MX",
            whatIs: "The Temporal Resident Card (Tarjeta de Residente Temporal) is the official document that proves your legal status as a temporary resident in Mexico.",
            whyIs: "Legally required for stays longer than 180 days. Necessary for employment, banking, and accessing various services in Mexico.",
            whereIs: "Collect at INM (Instituto Nacional de Migración) offices after entering Mexico with your visa.",
            whenIs: "Must be collected within 30 days of your arrival in Mexico. Failure to do so may result in fines or deportation.",
            docRequired: ["Valid Passport with visa", "Immigration form", "Payment of fees", "Photographs"],
            usefulLinks: ["INM office locations", "Online appointment system", "Fee payment information"]
        ),
        StepItem(
            id: "rfc-tax-id",
            title: "RFC Tax ID",
            date: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
            subtitle: "Required for employment and opening bank accounts.",
            order: 30,
            countryCode: "MX",
            whatIs: "RFC (Registro Federal de Contribuyentes) is Mexico's federal taxpayer registry code, similar to a tax identification number.",
            whyIs: "Essential for legal employment, opening bank accounts, issuing invoices, and any financial or business activities in Mexico.",
            whereIs: "Register at SAT (Servicio de Administración Tributaria) offices or through their online portal.",
            whenIs: "Obtain after getting your CURP and residence documentation, typically within the first month of legal residence.",
            docRequired: ["CURP", "Valid Passport", "Proof of Address", "Temporal Resident Card"],
            usefulLinks: ["SAT official portal", "Online RFC registration", "Tax obligations guide"]
        ),
        StepItem(
            id: "imss-registration",
            title: "IMSS Registration",
            date: Calendar.current.date(byAdding: .day, value: 12, to: Date()),
            subtitle: "Register for Mexico's social security system.",
            order: 40,
            countryCode: "MX",
            whatIs: "IMSS (Instituto Mexicano del Seguro Social) registration provides access to Mexico's social security system, including healthcare and social benefits.",
            whyIs: "Required for legal employment and provides access to public healthcare, maternity benefits, and retirement savings.",
            whereIs: "Register at local IMSS offices or through your employer if you have a job offer.",
            whenIs: "Complete registration once you have employment or within the first few months of residence.",
            docRequired: ["CURP", "RFC", "Temporal Resident Card", "Employment contract (if applicable)"],
            usefulLinks: ["IMSS office finder", "Benefits overview", "Registration process guide"]
        ),
        StepItem(
            id: "bank-account-mx",
            title: "Bank Account Setup",
            date: Calendar.current.date(byAdding: .day, value: 18, to: Date()),
            subtitle: "Open a Mexican bank account for local transactions.",
            order: 50,
            countryCode: "MX",
            whatIs: "Setting up a Mexican bank account provides access to local banking services, debit cards, and financial management in Mexico.",
            whyIs: "Necessary for receiving salary, paying rent, managing utilities, and conducting daily financial transactions in Mexico.",
            whereIs: "Visit major Mexican banks like BBVA México, Santander, Banorte, or Banamex. Many offer services for foreign residents.",
            whenIs: "Open after obtaining your temporal resident card and tax documentation, typically within the first 1-2 months.",
            docRequired: ["Temporal Resident Card", "RFC", "CURP", "Proof of Address", "Initial deposit"],
            usefulLinks: ["Bank services comparison", "Foreigner banking guide", "Required documentation checklist"]
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
