//
//  AsymmetricPublicKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Sodium
import Foundation

public struct AsymmetricPublicKey: Key {
    public let version: Version
    public let material: Data

    let publicBytes: Int = Sodium().sign.PublicKeyBytes

    var encode: String { return material.base64UrlNpEncoded }

    init (material: Data, version: Version = .v2) throws {
        switch version {
        case .v2:
            guard material.count == publicBytes else {
                throw Exception.badLength(
                    "Public key must be 32 bytes long; \(material.count) given."
                )
            }
        }

        self.version  = version
        self.material = material
    }

    init (base64: String, version: Version = .v2) throws {
        guard let decoded = Data(base64UrlNpEncoded: base64) else {
            throw Exception.badEncoding("Could not base64 URL decode.")
        }
        try self.init(material: decoded, version: version)
    }

    enum Exception: Error {
        case badLength(String)
        case badEncoding(String)
    }
}
