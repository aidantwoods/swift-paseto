//
//  V1LocalSymmetricKey.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation
import CryptoSwift

extension Version1.Local {
    public struct SymmetricKey {
        public let material: Data

        public init (material: Data) {
            self.material = material
        }
    }
}

extension Version1.Local.SymmetricKey: Paseto.SymmetricKey {
    public typealias Module = Version1.Local
}

extension Version1.Local.SymmetricKey {
    public init() {
        self.init(
            material: sodium.randomBytes.buf(length: Version1.Local.keyBytes)!
        )
    }

    func split(salt: Data) throws -> (Ek: Data, Ak: Data) {
        guard salt.count == 16 else {
            throw Exception.badSalt("Salt must be exactly 16 bytes")
        }

        let salt16 = salt[..<16]

        let encKey = try HKDF(
            password: material.bytes,
            salt: salt16.bytes,
            info: Array("paseto-encryption-key".utf8),
            keyLength: 32,
            variant: .sha384
        ).calculate()

        let authKey = try HKDF(
            password: material.bytes,
            salt: salt16.bytes,
            info: Array("paseto-auth-key-for-aead".utf8),
            keyLength: 32,
            variant: .sha384
        ).calculate()

        return (Ek: Data(encKey), Ak: Data(authKey))
    }
}

extension Version1.Local.SymmetricKey {
    enum Exception: Error {
        case badSalt(String)
    }
}
