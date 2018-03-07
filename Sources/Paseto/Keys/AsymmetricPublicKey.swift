//
//  AsymmetricPublicKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public struct AsymmetricPublicKey {
    public let version: Version
    public let material: Data

    init (material: Data, version: Version = .v2) throws {
        switch version {
        case .v2:
            guard material.count == Sign.PublicKeyBytes else {
                throw Exception.badLength(
                    "Public key must be 32 bytes long; \(material.count) given."
                )
            }
        }

        self.version  = version
        self.material = material
    }
}

extension AsymmetricPublicKey: Key {
    public init (encoded: String, version: Version = .v2) throws {
        guard let decoded = Data(base64UrlNoPad: encoded) else {
            throw Exception.badEncoding("Could not base64 URL decode.")
        }
        try self.init(material: decoded, version: version)
    }
}

extension AsymmetricPublicKey {
    enum Exception: Error {
        case badLength(String)
        case badEncoding(String)
    }
}
