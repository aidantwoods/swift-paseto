//
//  Data.swift
//  Paseto
//
//  Created by Aidan Woods on 13/05/2018.
//

import Foundation

extension Data: PureBytesRepresentable, BytesRepresentable {
    public var bytes: Bytes { return Bytes(self) }

    public init (bytes: Bytes) {
        self.init(bytes)
    }
}
