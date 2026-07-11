//
//  TagStore.swift
//  TagAlong
//
//  Created by Ben Gottlieb on 3/28/26.
//

import SwiftUI

/// The central registry for all tags seen by the app. Tags register
/// automatically when decoded, loaded from CloudKit, created in an
/// `AddTagsField`, or displayed in a `TagsView`, so colors stay consistent
/// everywhere. Known tags persist to disk between launches.
@available(iOS 17, macOS 14, *)
@MainActor @Observable public class TagStore {
	public static let instance = TagStore()

	public internal(set) var knownTags: [String: Tag] = [:]

	/// Supplies a color for newly registered tags that don't have one.
	/// Defaults to a stable color derived from the tag's name.
	@ObservationIgnored public var colorAssigner: (Tag) -> TagColor = { .generated(for: $0.name) }

	/// Called after the set of known tags changes; use this to mirror
	/// registrations elsewhere (e.g. CloudKit).
	@ObservationIgnored public var onTagsChanged: (([Tag]) -> Void)?

	@ObservationIgnored var persistenceURL: URL?
	@ObservationIgnored var saveTask: Task<Void, Never>?

	init(persistenceURL: URL? = TagStore.defaultPersistenceURL) {
		self.persistenceURL = persistenceURL
		loadPersistedTags()
	}

	public func register(_ tag: Tag, color: TagColor? = nil) {
		var newTag = tag
		if let color { newTag.color = color }
		if newTag.color == nil { newTag.color = knownTags[tag.id]?.color }
		if newTag.color == nil { newTag.color = colorAssigner(newTag) }

		if let existing = knownTags[tag.id], existing.name == newTag.name, existing.color == newTag.color { return }
		knownTags[tag.id] = newTag
		onTagsChanged?(Array(knownTags.values))
		scheduleSave()
	}

	public func register(_ tags: TagCollection) {
		// `Tag` is itself a TagCollection, so force the single-tag overload
		for tag in tags.tags { register(tag, color: nil) }
	}

	public func color(for tag: Tag) -> Color {
		if let known = knownTags[tag.id]?.color { return known.swiftUIColor }
		if let color = tag.color { return color.swiftUIColor }

		return TagColor.generated(for: tag.name).swiftUIColor
	}
}

@available(iOS 17, macOS 14, *)
public extension TagStore {
	static nonisolated func register(_ tag: Tag, color: TagColor? = nil) {
		Task { @MainActor in
			instance.register(tag, color: color)
		}
	}
}
