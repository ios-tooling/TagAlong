//
//  TagStore.swift
//  TagAlong
//
//  Created by Ben Gottlieb on 3/28/26.
//

import SwiftUI

@available(iOS 17.0, macOS 15, *)
@MainActor @Observable public class TagStore {
	public static let instance = TagStore()
	
	var knownTags: [String: Tag] = [:]
	
	public func register(_ tag: Tag, color: TagColor? = nil) {
		var newTag = tag
		if let color { newTag.color = color }
		if newTag.color == nil { newTag.color = knownTags[tag.id]?.color }
		knownTags[tag.id] = newTag
	}
	
	public func color(for tag: Tag) -> Color {
		if let known = knownTags[tag.id]?.color { return known.swiftUIColor }
        if let color = tag.color { return color.swiftUIColor }

		return tag.name.data(using: .utf8)?.extractColor() ?? .black
	}
}

@available(iOS 17.0, macOS 15, *)
public extension TagStore {
	static nonisolated func register(_ tag: Tag, color: TagColor? = nil) {
		Task { @MainActor in
			instance.register(tag, color: color)
		}
	}
}

extension Data {
	func extractColor() -> Color? {
		let count = count
		if count >= 8 {
			let integer = withUnsafeBytes { rawBuffer in
				rawBuffer.load(as: UInt64.self)
			}
			return Color(hex: integer)
		}
		if count >= 4 {
			let integer = withUnsafeBytes { rawBuffer in
				rawBuffer.load(as: UInt32.self)
			}
			return Color(hex: integer)
		}

		if count >= 3 {
			let integer = (Data([0]) + self).withUnsafeBytes { rawBuffer in
				rawBuffer.load(as: UInt32.self)
			}
			return Color(hex: integer)
		}

		return nil
	}
}
