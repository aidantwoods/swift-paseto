//
//  AsymmetricPublicKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public struct AsymmetricPublicKey<V: Implementation>: VersionedKey {
    typealias VersionType = V
    public let material: Data

    public init (material: Data) throws {
        switch AsymmetricPublicKey.version {
        case .v2:
            guard material.count == Sign.PublicKeyBytes else {
                throw Exception.badLength(
                    "Public key must be 32 bytes long; \(material.count) given."
                )
            }
        }

        self.material = material
    }
}

public extension AsymmetricPublicKey {
    enum Exception: Error {
        case badLength(String)
    }
}
