//
//  AsymmetricPublicKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public struct AsymmetricPublicKey<V: Implementation> {
    public let material: Data

    init (material: Data) throws {
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

    public static var version: Version {
        return Version(implementation: V.self)
    }
}

extension AsymmetricPublicKey: Key {
    public init (encoded: String) throws {
        guard let decoded = Data(base64UrlNoPad: encoded) else {
            throw Exception.badEncoding("Could not base64 URL decode.")
        }
        try self.init(material: decoded)
    }
}

extension AsymmetricPublicKey {
    enum Exception: Error {
        case badLength(String)
        case badEncoding(String)
    }
}
