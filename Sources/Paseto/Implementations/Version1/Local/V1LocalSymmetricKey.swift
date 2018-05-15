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
        public static let length = 32
        public let material: Bytes

        public init (material: Bytes) {
            self.material = material
        }

        public init () {
            self.init(bytes: Util.random(len: Module.SymmetricKey.length))!
        }

    }
}

extension Version1.Local.SymmetricKey: Paseto.SymmetricKey {
    public typealias Module = Version1.Local
}

extension Version1.Local.SymmetricKey {

    func split(salt: BytesRepresentable) throws -> (Ek: Bytes, Ak: Bytes) {
        let saltBytes = salt.bytes
        guard saltBytes.count == 16 else {
            throw Exception.badSalt("Salt must be exactly 16 bytes")
        }

        let encKey = try HKDF(
            password: material,
            salt: saltBytes,
            info: "paseto-encryption-key".bytes,
            keyLength: 32,
            variant: .sha384
        ).calculate()

        let authKey = try HKDF(
            password: material,
            salt: saltBytes,
            info: "paseto-auth-key-for-aead".bytes,
            keyLength: 32,
            variant: .sha384
        ).calculate()

        return (Ek: encKey, Ak: authKey)
    }
}

extension Version1.Local.SymmetricKey {
    enum Exception: Error {
        case badSalt(String)
    }
}
