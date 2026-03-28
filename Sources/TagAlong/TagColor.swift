//
//  File.swift
//  TagAlong
//
//  Created by Ben Gottlieb on 3/27/26.
//

import Foundation

public struct TagColor: Codable, Sendable, Hashable {
	public let rawValue: String
	
	public init(_ rawValue: String) { self.rawValue = rawValue }
	
	public static let red    = TagColor("#FF0000")
	public static let orange = TagColor("#FFA500")
	public static let yellow = TagColor("#FFFF00")
	public static let green  = TagColor("#008000")
	public static let blue   = TagColor("#0000FF")
	public static let purple = TagColor("#800080")
	public static let pink   = TagColor("#FFC0CB")
	public static let brown  = TagColor("#A52A2A")
	public static let gray   = TagColor("#808080")
}

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 17, macOS 14, *)
extension TagColor {
	public var swiftUIColor: Color {
		Color(hex: rawValue)
	}
}

@available(iOS 17, macOS 14, *)
extension Color {
	var luminosity: Double {
		#if os(macOS)
				NSColor(self).luminosity
		#else
				UIColor(self).luminosity
		#endif
	}

	var textColor: Color {
		luminosity <= 0.50 ? .white : .black
	}
	
	init(hex: String) {
		let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
		guard let int = UInt64(hex, radix: 16) else { self = .gray; return }
		self.init(hex: int, sizeHint: hex.count)
	}

	init(hex int: UInt32) {
		self.init(hex: UInt64(int), sizeHint: 4)
	}
	
	init(hex int: UInt64, sizeHint: Int = 8) {
		let r, g, b, a: Double
		switch sizeHint {
		case 3:
			r = Double((int >> 8) & 0xF) / 15
			g = Double((int >> 4) & 0xF) / 15
			b = Double(int & 0xF) / 15
			a = 1
		case 4:
			r = Double((int >> 12) & 0xF) / 15
			g = Double((int >> 8) & 0xF) / 15
			b = Double((int >> 4) & 0xF) / 15
			a = Double(int & 0xF) / 15
		case 6:
			r = Double((int >> 16) & 0xFF) / 255
			g = Double((int >> 8) & 0xFF) / 255
			b = Double(int & 0xFF) / 255
			a = 1
		case 8:
			r = Double((int >> 24) & 0xFF) / 255
			g = Double((int >> 16) & 0xFF) / 255
			b = Double((int >> 8) & 0xFF) / 255
			a = Double(int & 0xFF) / 255
		default:
			self = .gray; return
		}
		self.init(red: r, green: g, blue: b, opacity: a)
	}
}
#endif

#if os(macOS)
extension NSColor {
	var luminosity: Double {
		var r: CGFloat = 0.0
		var g: CGFloat = 0.0
		var b: CGFloat = 0.0
		var a: CGFloat = 0.0
		self.getRed(&r, green: &g, blue: &b, alpha: &a)
		return 0.2126 * r + g * 0.7152 + 0.0722 * b
	}
}
#endif

#if os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
extension UIColor {
	var luminosity: Double {
		var r: CGFloat = 0.0
		var g: CGFloat = 0.0
		var b: CGFloat = 0.0
		var a: CGFloat = 0.0
		self.getRed(&r, green: &g, blue: &b, alpha: &a)
		return 0.2126 * r + g * 0.7152 + 0.0722 * b
	}
}
#endif
