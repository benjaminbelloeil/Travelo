//
//  TabNavigationEnvironment.swift
//  Travelo
//
//  Created by Dawar Hasnain on 10/24/25.
//

import SwiftUI

// Environment key for tab selection
struct TabSelectionKey: EnvironmentKey {
    static let defaultValue: Binding<Tab> = .constant(.home)
}

extension EnvironmentValues {
    var tabSelection: Binding<Tab> {
        get { self[TabSelectionKey.self] }
        set { self[TabSelectionKey.self] = newValue }
    }
}

// Environment key for showing country selection
struct ShowCountrySelectionKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var showCountrySelection: () -> Void {
        get { self[ShowCountrySelectionKey.self] }
        set { self[ShowCountrySelectionKey.self] = newValue }
    }
}