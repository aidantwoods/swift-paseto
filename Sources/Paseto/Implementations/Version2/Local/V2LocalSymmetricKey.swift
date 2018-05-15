//
//  V2LocalSymmetricKey.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

public extension Version2.Local {
    struct SymmetricKey: Paseto.SymmetricKey {
        public let material: Bytes
        public typealias Module = Version2.Local

        public init (material: Bytes) {
            self.material = material
        }
    }
}

extension Version2.Local.SymmetricKey {
    public init () {
        self.init(
            bytes: sodium.randomBytes.buf(length: Int(Aead.keyBytes))!
        )!
    }
}
