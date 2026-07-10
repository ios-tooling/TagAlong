//
//  Tag.swift
//  TagAlong
//
//  Created by Ben Gottlieb on 3/27/26.
//

import SwiftUI

public struct Tag: Codable, Sendable, Hashable, Equatable, Identifiable {
	public var name: String
	public var color: TagColor?
	public var id: String
	
	enum CodingKeys: CodingKey { case name, color }

	public init(_ name: String, color: TagColor? = nil) {
		self.name = name
		self.color = color
		self.id = name.lowercased()
	}
	
	public static func ==(lhs: Tag, rhs: Tag) -> Bool {
		lhs.id == rhs.id
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(name.lowercased())
	}
	
	
	public init(from decoder: any Decoder) throws {
		if let single = try? decoder.singleValueContainer(), let string = try? single.decode(String.self) {
			self.name = string
			self.id = string.lowercased()
			TagStore.register(self)
			return
		}

		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decode(String.self, forKey: .name)
		self.color = try container.decodeIfPresent(TagColor.self, forKey: .color)
		self.id = self.name.lowercased()
		TagStore.register(self)
	}
	
	public func encode(to encoder: any Encoder) throws {
		if color == nil {
			var container = encoder.singleValueContainer()
			try container.encode(name)
		} else {
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encode(name, forKey: .name)
			try container.encode(color, forKey: .color)
		}
	}
	
	@MainActor public var tagColor: Color {
		TagStore.instance.color(for: self)
	}
}

