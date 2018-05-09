//
//  SymmetricKey.swift
//  Paseto_V2
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation
import Paseto_Core

public extension Version2.Local {
    struct SymmetricKey: Paseto_Core.SymmetricKey {
        public let material: Data
        public typealias Module = Version2.Local

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
