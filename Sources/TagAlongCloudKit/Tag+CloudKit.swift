//
//  Tag+CloudKit.swift
//  TagAlongCloudKit
//
//  Created by Ben Gottlieb on 4/8/26.
//

import CloudKit
import CloudSeeding
import TagAlong

extension CKRecordField<String> {
	public static let tagName = CKRecordField.string("tagName")
	public static let tagColor = CKRecordField.string("tagColor")
}

extension CKRecordField<[Tag]> {
	public static let tags = CKRecordField.codable("tags", DataType.self)
}

@available(iOS 17, macOS 14, *)
extension Tag {
	public static var ckRecordType: CKRecord.RecordType { "Tag" }

	public func populate(_ record: CKRecord) {
		record[.tagName] = name
		record[.tagColor] = color?.rawValue
	}

	public init?(from record: CKRecord) {
		guard let name: String = record[.tagName] else { return nil }
		let colorRaw: String? = record[.tagColor]
		self.init(name, color: colorRaw.map { TagColor($0) })
		TagStore.register(self)
	}

	public func ckRecord(in zoneID: CKRecordZone.ID) -> CKRecord {
		let recordID = CKRecord.ID(recordName: id, zoneID: zoneID)
		let record = CKRecord(recordType: Self.ckRecordType, recordID: recordID)
		populate(record)
		return record
	}
}
