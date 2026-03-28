//
//  TagsView.swift
//  TagAlong
//
//  Created by Ben Gottlieb on 3/27/26.
//

import SwiftUI

/// Displays a horizontal row of tag capsules with name and color.
@available(iOS 17, macOS 14, *)
public struct TagsView: View {
	let tags: [Tag]
	
	public init(tags: TagCollection) {
		self.tags = tags.tags
	}
	
	public var body: some View {
		if !tags.isEmpty {
			HStack(spacing: 4) {
				ForEach(tags, id: \.self) { tag in
					Text(tag.name)
						.font(.caption2)
						.padding(.horizontal, 6)
						.padding(.vertical, 2)
						.background(tag.color.swiftUIColor.opacity(0.2))
						.foregroundStyle(tag.color.swiftUIColor)
						.clipShape(Capsule())
				}
			}
		}
	}
}
