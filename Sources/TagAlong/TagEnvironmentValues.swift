//
//  TagEnvironmentValues.swift
//  TagAlong
//

import SwiftUI

public extension EnvironmentValues {
    @Entry var onTagCreated: ((Tag) -> Void)? = nil
    @Entry var onTagRemoved: ((Tag) -> Void)? = nil
    /// Called to supply a color for any tag that doesn't already have one.
    @Entry var tagColorProvider: ((Tag) -> TagColor)? = nil
}

public extension View {
    func onTagCreated(_ action: @escaping (Tag) -> Void) -> some View {
        environment(\.onTagCreated, action)
    }

    func onTagRemoved(_ action: @escaping (Tag) -> Void) -> some View {
        environment(\.onTagRemoved, action)
    }

    @available(*, deprecated, message: "Set TagStore.instance.colorAssigner instead; the store assigns and records colors when tags are registered.")
    func tagColorProvider(_ provider: @escaping (Tag) -> TagColor) -> some View {
        environment(\.tagColorProvider, provider)
    }
}
