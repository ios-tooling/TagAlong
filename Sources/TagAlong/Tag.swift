//
//  Tag.swift
//  TagAlong
//
//  Created by Ben Gottlieb on 3/27/26.
//

import Foundation

public struct Tag: Codable, Sendable, Hashable {
	 public let name: String
	 public let color: TagColor

	 public init(_ name: String, color: TagColor) {
		  self.name = name
		  self.color = color
	 }
}

