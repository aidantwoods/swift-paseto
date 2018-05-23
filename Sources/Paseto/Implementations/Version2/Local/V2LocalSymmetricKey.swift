//
//  V2LocalSymmetricKey.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

public extension Version2.Local {
    struct SymmetricKey: Paseto.SymmetricKey {
        public static let length = Aead.keyBytes

        public let material: Bytes
        public typealias Module = Version2.Local

        public init (material: Bytes) {
            self.material = material
        }

        public init () {
            self.init(bytes: Util.random(length: Module.SymmetricKey.length))!
        }
    }
}
