//
//  FlowLayout.swift
//  TagAlong
//

import SwiftUI

/// A simple wrapping flow layout: lays out subviews left-to-right and wraps to
/// the next line when the proposed width is exceeded. Each subview keeps its
/// own intrinsic size — useful for capsule-style tags or chips.
///
/// When `stretchLast` is `true` the final subview is widened to fill the
/// remaining space on its line (useful for an inline text field).
public struct FlowLayout: Layout {
	public var spacing: CGFloat
	public var lineSpacing: CGFloat
	public var stretchLast: Bool

	public init(spacing: CGFloat = 4, lineSpacing: CGFloat = 4, stretchLast: Bool = false) {
		self.spacing = spacing
		self.lineSpacing = lineSpacing
		self.stretchLast = stretchLast
	}

	public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
		let maxWidth = proposal.width ?? .infinity
		let lines = makeLines(maxWidth: maxWidth, subviews: subviews)
		let height = lines.reduce(0) { $0 + $1.height } + lineSpacing * CGFloat(max(0, lines.count - 1))
		let contentWidth = lines.map(\.width).max() ?? 0
		let width: CGFloat
		if stretchLast, let proposed = proposal.width, proposed.isFinite {
			width = proposed
		} else {
			width = contentWidth
		}
		return CGSize(width: width, height: height)
	}

	public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
		let lines = makeLines(maxWidth: bounds.width, subviews: subviews)
		let lastSubviewIndex = subviews.count - 1
		var y = bounds.minY
		for line in lines {
			var x = bounds.minX
			for position in line.indices.indices {
				let subviewIndex = line.indices[position]
				let size = line.sizes[position]
				let proposedWidth: CGFloat
				if stretchLast, subviewIndex == lastSubviewIndex {
					proposedWidth = max(size.width, bounds.maxX - x)
				} else {
					proposedWidth = size.width
				}
				subviews[subviewIndex].place(
					at: CGPoint(x: x, y: y),
					anchor: .topLeading,
					proposal: ProposedViewSize(width: proposedWidth, height: size.height)
				)
				x += size.width + spacing
			}
			y += line.height + lineSpacing
		}
	}

	private struct Line {
		var indices: [Int] = []
		var sizes: [CGSize] = []
		var width: CGFloat = 0
		var height: CGFloat = 0
	}

	private func makeLines(maxWidth: CGFloat, subviews: Subviews) -> [Line] {
		var lines: [Line] = [Line()]
		for index in subviews.indices {
			let natural = subviews[index].sizeThatFits(.unspecified)
			let size = CGSize(width: min(natural.width, maxWidth), height: natural.height)
			let projectedWidth = lines[lines.count - 1].width
				+ (lines[lines.count - 1].indices.isEmpty ? 0 : spacing)
				+ size.width
			if projectedWidth > maxWidth, !lines[lines.count - 1].indices.isEmpty {
				lines.append(Line())
			}
			var current = lines[lines.count - 1]
			if !current.indices.isEmpty { current.width += spacing }
			current.indices.append(index)
			current.sizes.append(size)
			current.width += size.width
			current.height = max(current.height, size.height)
			lines[lines.count - 1] = current
		}
		return lines
	}
}
