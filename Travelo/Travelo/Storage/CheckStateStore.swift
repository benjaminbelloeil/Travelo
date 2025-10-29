//
//  CheckStateStore.swift
//  Travelo
//
//  Created by Benjamin Belloeil on 10/23/25.
//

import Foundation
import Combine

/// Persists per-user check/uncheck without auth (UserDefaults).
/// Prefix includes a template version and the selected country so you can
/// change the list safely and have per-country states.
final class CheckStateStore: ObservableObject {
    private let defaults: UserDefaults
    private var keyPrefix: String
    let objectWillChange = PassthroughSubject<Void, Never>()

    init(countryCode: String, templateVersion: Int = 1, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.keyPrefix = "checkstate_v\(templateVersion)_\(countryCode)_"
    }

    /// Call this if the country changes (e.g., Mexico → Italy)
    func updateCountry(_ countryCode: String, templateVersion: Int = 1) {
        self.keyPrefix = "checkstate_v\(templateVersion)_\(countryCode)_"
        objectWillChange.send()
    }

    func isDone(_ id: String) -> Bool {
        defaults.bool(forKey: keyPrefix + id)
    }

    func setDone(_ done: Bool, id: String) {
        defaults.set(done, forKey: keyPrefix + id)
        objectWillChange.send()
    }

    func toggle(_ id: String) { setDone(!isDone(id), id: id) }

    /// Optional helpers
    func reset(ids: [String]) {
        ids.forEach { defaults.removeObject(forKey: keyPrefix + $0) }
        objectWillChange.send()
    }
}
