//
//  Tag.swift
//  TagAlong
//
//  Created by Ben Gottlieb on 3/27/26.
//

import Foundation

public struct Tag: Codable, Sendable, Hashable, Equatable {
    public let name: String
    public let color: TagColor
    
    public init(_ name: String, color: TagColor) {
        self.name = name
        self.color = color
    }
    
    public static func ==(lhs: Tag, rhs: Tag) -> Bool {
        lhs.name.caseInsensitiveCompare(rhs.name) == .orderedSame
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name.lowercased())
    }
}

