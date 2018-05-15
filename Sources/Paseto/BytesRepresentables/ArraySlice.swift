//
//  ArraySlice.swift
//  Paseto
//
//  Created by Aidan Woods on 13/05/2018.
//

extension ArraySlice: PureBytesRepresentable, BytesRepresentable
    where Element == UInt8
{
    public var bytes: Bytes { return Bytes(self) }

    public init (bytes: Bytes) {
        self.init(bytes)
    }
}
