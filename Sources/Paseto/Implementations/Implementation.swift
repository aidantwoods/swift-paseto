//
//  Version.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public protocol Implementation {
    static var version: Version { get }

    static func encrypt(
        _ message: Data, with key: SymmetricKey<Self>, footer: Data
    ) -> Blob<EncryptedPayload>

    static func decrypt(
        _ encrypted: Blob<EncryptedPayload>,
        with key: SymmetricKey<Self>,
        footer: Data
    ) throws -> Data

    static func sign(
        _ data: Data, with key: AsymmetricSecretKey<Self>, footer: Data
    ) -> Blob<SignedPayload>

    static func verify(
        _ signedMessage: Blob<SignedPayload>,
        with key: AsymmetricPublicKey<Self>,
        footer: Data
    ) throws -> Data
}

extension Implementation {
    static func encrypt(
        _ message: Data, with key: SymmetricKey<Self>
    ) -> Blob<EncryptedPayload> {
        return encrypt(message, with: key, footer: Data("".utf8))
    }

    static func decrypt(
        _ encrypted: Blob<EncryptedPayload>, with key: SymmetricKey<Self>
    ) throws -> Data {
        return try decrypt(encrypted, with: key, footer: Data("".utf8))
    }

    static func sign(
        _ data: Data, with key: AsymmetricSecretKey<Self>
    ) -> Blob<SignedPayload> {
        return sign(data, with: key, footer: Data())
    }

    static func verify(
        _ signedMessage: Blob<SignedPayload>,
        with key: AsymmetricPublicKey<Self>
    ) throws -> Data {
        return try verify(signedMessage, with: key, footer: Data())
    }
}

extension Implementation {
    static func decrypt(
        _ encrypted: Blob<EncryptedPayload>,
        with key: SymmetricKey<Self>,
        footer: Data
    ) -> Data? {
        return try? decrypt(encrypted, with: key, footer: footer)
    }

    static func decrypt(
        _ encrypted: Blob<EncryptedPayload>, with key: SymmetricKey<Self>
        ) -> Data? {
        return try? decrypt(encrypted, with: key)
    }

    static func verify(
        _ signedMessage: Blob<SignedPayload>,
        with key: AsymmetricPublicKey<Self>,
        footer: Data
    ) -> Data? {
        return try? verify(signedMessage, with: key, footer: footer)
    }

    static func verify(
        _ signedMessage: Blob<SignedPayload>,
        with key: AsymmetricPublicKey<Self>
    ) -> Data? {
        return try? verify(signedMessage, with: key)
    }
}

extension Implementation {
    static func encrypt(
        _ message: String, with key: SymmetricKey<Self>
    ) -> Blob<EncryptedPayload> {
        return encrypt(Data(message.utf8), with: key)
    }

    static func decrypt(
        _ encrypted: Blob<EncryptedPayload>, with key: SymmetricKey<Self>
    ) -> String? {
        return decrypt(encrypted, with: key)?.utf8String
    }

    static func sign(
        _ string: String, with key: AsymmetricSecretKey<Self>
    ) -> Blob<SignedPayload> {
        return sign(Data(string.utf8), with: key)
    }

    static func verify(
        _ signedMessage: Blob<SignedPayload>,
        with key: AsymmetricPublicKey<Self>
    ) -> String? {
        return verify(signedMessage, with: key)?.utf8String
    }
}

