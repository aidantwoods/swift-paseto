//
//  AsymmetricPublicKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public struct AsymmetricPublicKey<V: Implementation>: Key {
    typealias VersionType = V
    public let material: Data

    public init (material: Data) throws {
        switch AsymmetricPublicKey.version {
        case .v1:
            fatalError("""
                Not implemented.
                Swift's standard library requires at least OSX 10.13 to use the
                RSA that we need. There isn't much value in only implementing
                this for one platform. Alternative solution is sought.
                """
            )

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
