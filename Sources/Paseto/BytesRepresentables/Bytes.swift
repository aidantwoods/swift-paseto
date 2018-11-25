//
//  Bytes.swift
//  Paseto
//
//  Created by Aidan Woods on 13/05/2018.
//

public typealias Bytes = Array<UInt8>

public extension Array where Element == UInt8 {
    init (count: Int) {
        self.init(repeating: 0, count: count)
    }
}

extension Array: PureBytesRepresentable, BytesRepresentable
    where Element == UInt8
{
    public var bytes: Bytes { return self }

    public init (bytes: Bytes) {
        self = bytes
    }
}

extension Array where Element == UInt8 {
    init? (fromBase64 encoded: String) {
        guard let decoded = sodium.utils.base642bin(
            encoded,
            variant: .URLSAFE_NO_PADDING
        ) else { return nil }

        self = decoded
    }
}
