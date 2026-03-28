//
//  File.swift
//  TagAlong
//
//  Created by Ben Gottlieb on 3/27/26.
//

import Foundation

public protocol TagCollection {
	var tags: [Tag] { get }
}


extension Tag: TagCollection {
	public var tags: [Tag] { [self] }
}

extension [Tag]: TagCollection {
	public var tags: [Tag] { self }
}
