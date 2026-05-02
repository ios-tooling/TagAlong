//
//  FlowLayout.swift
//  TagAlong
//

import SwiftUI

/// A simple wrapping flow layout: lays out subviews left-to-right and wraps to
/// the next line when the proposed width is exceeded. Each subview keeps its
/// own intrinsic size — useful for capsule-style tags or chips.
@available(iOS 16, macOS 13, watchOS 10, *)
public struct FlowLayout: Layout {
	public var spacing: CGFloat
	public var lineSpacing: CGFloat

	public init(spacing: CGFloat = 4, lineSpacing: CGFloat = 4) {
		self.spacing = spacing
		self.lineSpacing = lineSpacing
	}

	public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
		let maxWidth = proposal.width ?? .infinity
		let lines = makeLines(maxWidth: maxWidth, subviews: subviews)
		let height = lines.reduce(0) { $0 + $1.height } + lineSpacing * CGFloat(max(0, lines.count - 1))
		let width = lines.map(\.width).max() ?? 0
		return CGSize(width: width, height: height)
	}

	public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
		let lines = makeLines(maxWidth: bounds.width, subviews: subviews)
		var y = bounds.minY
		for line in lines {
			var x = bounds.minX
			for position in line.indices.indices {
				let subviewIndex = line.indices[position]
				let size = line.sizes[position]
				subviews[subviewIndex].place(
					at: CGPoint(x: x, y: y),
					anchor: .topLeading,
					proposal: ProposedViewSize(size)
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
			let size = subviews[index].sizeThatFits(.unspecified)
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
