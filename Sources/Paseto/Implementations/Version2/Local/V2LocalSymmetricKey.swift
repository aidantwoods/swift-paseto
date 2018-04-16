//
//  V2LocalSymmetricKey.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

public extension Version2.Local {
    struct SymmetricKey: Paseto.SymmetricKey {
        public let material: Data
        public typealias Implementation = Version2.Local

        public init (material: Data) {
            self.material = material
        }
    }
}

extension Version2.Local.SymmetricKey {
    public init () {
        self.init(
            material: sodium.randomBytes.buf(length: Int(Aead.keyBytes))!
        )
    }
}
