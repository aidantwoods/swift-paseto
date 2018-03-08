//
//  SymmetricKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Sodium
import Foundation

public struct SymmetricKey {
    public let version: Version
    public let material: Data

    init (material: Data, version: Version = .v2) {
        self.material = material
        self.version = version
    }

    init (version: Version = .v2) {
        switch version {
        case .v2:
            self.init(
                material: sodium.randomBytes.buf(length: Int(Aead.keyBytes))!,
                version: version
            )
        }
    }
}

extension SymmetricKey: Key {
    public init (encoded: String, version: Version = .v2) throws {
        guard let decoded = Data(base64UrlNoPad: encoded) else {
            throw Exception.badEncoding("Could not base64 URL decode.")
        }
        self.init(material: decoded, version: version)
    }
}

extension SymmetricKey {
    enum Exception: Error {
        case badEncoding(String)
    }
}
