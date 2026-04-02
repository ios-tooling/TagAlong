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
	let showRemove: Bool
	let onTap: ((Tag) -> Void)?

    public init(tags: TagCollection, showRemove: Bool = false, onTap: ((Tag) -> Void)? = nil) {
        self.tags = tags.tags
        self.showRemove = showRemove
        self.onTap = onTap
    }

    public init(_ tags: TagCollection, showRemove: Bool = false, onTap: ((Tag) -> Void)? = nil) {
        self.tags = tags.tags
        self.showRemove = showRemove
        self.onTap = onTap
    }

	public var body: some View {
		if !tags.isEmpty {
			HStack(spacing: 4) {
				ForEach(tags, id: \.self) { tag in
					tagCapsule(tag)
				}
			}
		}
	}

	private func tagCapsule(_ tag: Tag) -> some View {
		HStack(spacing: 3) {
			Text(tag.name)
			if showRemove {
				Image(systemName: "xmark")
					.font(.system(size: 8, weight: .bold))
			}
		}
		.font(.caption2)
		.padding(.horizontal, 6)
		.padding(.vertical, 2)
		.background(tag.tagColor)
		.foregroundStyle(tag.tagColor.textColor)
		.clipShape(Capsule())
		.onTapGesture { onTap?(tag) }
	}
}
