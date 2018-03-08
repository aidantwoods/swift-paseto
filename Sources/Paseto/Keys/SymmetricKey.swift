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

    init (material: Data) {
        self.material = material
    }

    init () {
        switch SymmetricKey.version {
        case .v2:
            self.init(
                material: sodium.randomBytes.buf(length: Int(Aead.keyBytes))!
            )
        }
    }

    public static var version: Version {
        return Version(implementation: V.self)
    }
}

extension SymmetricKey: Key {
    public init (encoded: String) throws {
        guard let decoded = Data(base64UrlNoPad: encoded) else {
            throw Exception.badEncoding("Could not base64 URL decode.")
        }
        self.init(material: decoded)
    }
}

extension SymmetricKey {
    enum Exception: Error {
        case badEncoding(String)
    }
}
