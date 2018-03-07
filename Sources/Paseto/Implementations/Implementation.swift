//
//  Version.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public protocol Implementation {
    static var version: Version { get }
//    static func encrypt(
//        _ data: Data, with key: SymmetricKey, footer: Data
//    ) -> Blob
//
//    static func decrypt(
//        _ data: Blob, with key: SymmetricKey, footer: Data
//    ) -> Data

    static func sign(
        _ data: Data, with key: AsymmetricSecretKey, footer: Data
    ) -> Blob<SignedPayload>

    static func verify(
        _ signedMessage: Blob<SignedPayload>,
        with key: AsymmetricPublicKey,
        footer: Data
    ) throws -> Data
}

extension Implementation {
//    static func encrypt(_ data: Data, with key: SymmetricKey) -> Blob {
//        return encrypt(data, with: key, footer: Data("".utf8))
//    }
//
//    static func decrypt(_ data: Blob, with key: SymmetricKey) -> Data {
//        return decrypt(data, with: key, footer: Data("".utf8))
//    }

    static func sign(
        _ data: Data, with key: AsymmetricSecretKey
    ) -> Blob<SignedPayload> {
        return sign(data, with: key, footer: Data())
    }

    static func verify(
        _ signedMessage: Blob<SignedPayload>, with key: AsymmetricPublicKey
    ) throws -> Data {
        return try verify(signedMessage, with: key, footer: Data())
    }
}

extension Implementation {
    static func verify(
        _ signedMessage: Blob<SignedPayload>,
        with key: AsymmetricPublicKey,
        footer: Data
    ) -> Data? {
        return try? verify(signedMessage, with: key, footer: footer)
    }

    static func verify(
        _ signedMessage: Blob<SignedPayload>, with key: AsymmetricPublicKey
    ) -> Data? {
        return try? verify(signedMessage, with: key)
    }
}

extension Implementation {
    static func sign(
        _ string: String, with key: AsymmetricSecretKey
    ) -> Blob<SignedPayload> {
        return sign(Data(string.utf8), with: key)
    }

    static func verify(
        _ signedMessage: Blob<SignedPayload>, with key: AsymmetricPublicKey
    ) -> String? {
        return verify(signedMessage, with: key)?.utf8String
    }
}

