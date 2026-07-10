//
//  TagColor+Generated.swift
//  TagAlong
//

import Foundation

public extension TagColor {
	/// A stable color derived from the tag's name, so uncolored tags look the
	/// same everywhere and across launches.
	static func generated(for name: String) -> TagColor {
		let data = Data(name.utf8)

		if data.count >= 8 {
			let integer = data.withUnsafeBytes { $0.load(as: UInt64.self) }
			return TagColor(String(format: "#%08X", UInt32(truncatingIfNeeded: integer)))
		}
		if data.count >= 4 {
			let integer = data.withUnsafeBytes { $0.load(as: UInt32.self) }
			return TagColor(String(format: "#%04X", integer & 0xFFFF))
		}
		if data.count >= 3 {
			let integer = (Data([0]) + data).withUnsafeBytes { $0.load(as: UInt32.self) }
			return TagColor(String(format: "#%04X", integer & 0xFFFF))
		}

		return TagColor("#000000")
	}
}
