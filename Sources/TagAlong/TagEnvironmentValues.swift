//
//  TagEnvironmentValues.swift
//  TagAlong
//

import SwiftUI

private struct OnTagCreatedKey: EnvironmentKey {
    static let defaultValue: ((Tag) -> Void)? = nil
}

private struct OnTagRemovedKey: EnvironmentKey {
    static let defaultValue: ((Tag) -> Void)? = nil
}

public extension EnvironmentValues {
    var onTagCreated: ((Tag) -> Void)? {
        get { self[OnTagCreatedKey.self] }
        set { self[OnTagCreatedKey.self] = newValue }
    }

    var onTagRemoved: ((Tag) -> Void)? {
        get { self[OnTagRemovedKey.self] }
        set { self[OnTagRemovedKey.self] = newValue }
    }
}

public extension View {
    func onTagCreated(_ action: @escaping (Tag) -> Void) -> some View {
        environment(\.onTagCreated, action)
    }

    func onTagRemoved(_ action: @escaping (Tag) -> Void) -> some View {
        environment(\.onTagRemoved, action)
    }
}
