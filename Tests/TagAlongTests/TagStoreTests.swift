//
//  TagStoreTests.swift
//  TagAlong
//

import Foundation
import Testing
@testable import TagAlong

// Swift Testing declares its own `Tag`; make sure we get the real one.
private typealias Tag = TagAlong.Tag

@MainActor
struct TagStoreTests {
	init() {
		// Keep test registrations out of the real Application Support file.
		TagStore.instance.persistenceURL = nil
	}

	@Test func assignsStableColorToNewTags() {
		let store = TagStore(persistenceURL: nil)
		store.register(Tag("swiftui"))
		let color = store.knownTags["swiftui"]?.color
		#expect(color != nil)

		let second = TagStore(persistenceURL: nil)
		second.register(Tag("swiftui"))
		#expect(second.knownTags["swiftui"]?.color == color)
	}

	@Test func explicitColorSurvivesColorlessReRegistration() {
		let store = TagStore(persistenceURL: nil)
		store.register(Tag("urgent", color: .red))
		store.register(Tag("urgent"))
		#expect(store.knownTags["urgent"]?.color == .red)
	}

	@Test func registeredColorWinsOverTagsOwnColor() {
		let store = TagStore(persistenceURL: nil)
		store.register(Tag("status", color: .blue))
		let localCopy = Tag("status", color: .green)
		#expect(store.color(for: localCopy) == TagColor.blue.swiftUIColor)
	}

	@Test func generatedColorIsDeterministic() {
		#expect(TagColor.generated(for: "alpha") == TagColor.generated(for: "alpha"))
		#expect(TagColor.generated(for: "alpha") != TagColor.generated(for: "omega"))
	}

	@Test func persistsAndReloadsKnownTags() {
		let url = FileManager.default.temporaryDirectory
			.appendingPathComponent(UUID().uuidString)
			.appendingPathComponent("tags.json")
		let store = TagStore(persistenceURL: url)
		store.register(Tag("alpha", color: .purple))
		store.register(Tag("beta"))
		store.save()

		let reloaded = TagStore(persistenceURL: url)
		#expect(reloaded.knownTags["alpha"]?.color == .purple)
		#expect(reloaded.knownTags["beta"]?.color == store.knownTags["beta"]?.color)
	}

	fileprivate nonisolated static func decodeTags(from data: Data) throws -> [Tag] {
		try JSONDecoder().decode([Tag].self, from: data)
	}

	@Test func decodingRegistersTagsWithTheSharedStore() async throws {
		let name = "decoded-\(UUID().uuidString.lowercased())"
		let data = try JSONEncoder().encode([Tag(name)])
		_ = try Self.decodeTags(from: data)

		// registration hops onto the main actor, so allow it a moment to land
		for _ in 0..<100 {
			if TagStore.instance.knownTags[name] != nil { break }
			try await Task.sleep(for: .milliseconds(10))
		}
		#expect(TagStore.instance.knownTags[name] != nil)
		#expect(TagStore.instance.knownTags[name]?.color != nil)
	}
}
