//
//  TagStore+Persistence.swift
//  TagAlong
//

import Foundation

extension TagStore {
	static nonisolated var defaultPersistenceURL: URL? {
		guard let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
		return base.appendingPathComponent("TagAlong", isDirectory: true).appendingPathComponent("known-tags.json")
	}

	func loadPersistedTags() {
		guard let url = persistenceURL, let data = try? Data(contentsOf: url) else { return }
		do {
			let tags = try JSONDecoder().decode([Tag].self, from: data)
			for tag in tags { knownTags[tag.id] = tag }
		} catch {
			print("TagAlong: failed to load known tags from \(url.path): \(error)")
		}
	}

	func scheduleSave() {
		saveTask?.cancel()
		saveTask = Task {
			try? await Task.sleep(for: .seconds(1))
			guard !Task.isCancelled else { return }
			self.save()
		}
	}

	public func save() {
		guard let url = persistenceURL else { return }
		do {
			try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
			let tags = knownTags.values.sorted { $0.id < $1.id }
			let data = try JSONEncoder().encode(tags)
			try data.write(to: url, options: .atomic)
		} catch {
			print("TagAlong: failed to save known tags to \(url.path): \(error)")
		}
	}
}
