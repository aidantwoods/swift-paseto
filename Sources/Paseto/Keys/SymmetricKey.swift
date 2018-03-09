//
//  SymmetricKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Sodium
import Foundation

public struct SymmetricKey<V: Implementation> {
    public let material: Data

    public init () {
        switch SymmetricKey.version {
        case .v2:
            self.init(
                material: sodium.randomBytes.buf(length: Int(Aead.keyBytes))!
            )
        }
    }

    public static var version: Version { return V.version }
}

extension SymmetricKey: Key {
    public init (material: Data) {
        self.material = material
    }
}
