//
//  String.swift
//  Paseto
//
//  Created by Aidan Woods on 13/05/2018.
//

import Foundation

extension String: BytesRepresentable {
    public var bytes: Bytes { return Bytes(self.utf8) }

    public init? (bytes: Bytes) {
        self.init(data: Data(bytes: bytes), encoding: .utf8)
    }
}
