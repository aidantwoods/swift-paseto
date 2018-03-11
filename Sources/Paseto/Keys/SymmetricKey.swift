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
        case .v1:
            self.init(
                material: sodium.randomBytes.buf(length: Version1.keyBytes)!
            )

        case .v2:
            self.init(
                material: sodium.randomBytes.buf(length: Int(Aead.keyBytes))!
            )
        }
    }
}

extension SymmetricKey: Key {
    typealias VersionType = V
    public init (material: Data) {
        self.material = material
    }
}
