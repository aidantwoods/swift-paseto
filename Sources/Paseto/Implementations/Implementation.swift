//
//  Version.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public protocol Implementation {
    static func encrypt(
        _ message: Data, with key: SymmetricKey<Self>, footer: Data
    ) throws -> Blob<Encrypted<Self>>

    static func decrypt(
        _ encrypted: Blob<Encrypted<Self>>, with key: SymmetricKey<Self>
    ) throws -> Data

    static func sign(
        _ data: Data, with key: AsymmetricSecretKey<Self>, footer: Data
    ) throws -> Blob<Signed<Self>>

    static func verify(
        _ signedMessage: Blob<Signed<Self>>, with key: AsymmetricPublicKey<Self>
    ) throws -> Data
}

public extension Implementation {
    static var version: Version { return Version(implementation: self) }
}

public extension Implementation {
    static func encrypt(
        _ message: Data, with key: SymmetricKey<Self>
    ) throws -> Blob<Encrypted<Self>> {
        return try encrypt(message, with: key, footer: Data())
    }

    static func sign(
        _ data: Data, with key: AsymmetricSecretKey<Self>
    ) throws -> Blob<Signed<Self>> {
        return try sign(data, with: key, footer: Data())
    }
}

public extension Implementation {
    static func encrypt(
        _ message: Data, with key: SymmetricKey<Self>, footer: Data = Data()
    ) -> Blob<Encrypted<Self>>? {
        return try? encrypt(message, with: key, footer: footer)
    }

    static func decrypt(
        _ encrypted: Blob<Encrypted<Self>>, with key: SymmetricKey<Self>
    ) -> Data? {
        return try? decrypt(encrypted, with: key)
    }

    static func sign(
        _ data: Data, with key: AsymmetricSecretKey<Self>, footer: Data
    ) -> Blob<Signed<Self>>? {
        return try? sign(data, with: key, footer: footer)
    }

    static func verify(
        _ signedMessage: Blob<Signed<Self>>, with key: AsymmetricPublicKey<Self>
    ) -> Data? {
        return try? verify(signedMessage, with: key)
    }
}

public extension Implementation {
    static func encrypt(
        _ message: String, with key: SymmetricKey<Self>, footer: Data = Data()
    ) throws -> Blob<Encrypted<Self>> {
        return try encrypt(Data(message.utf8), with: key, footer: footer)
    }

    static func sign(
        _ string: String,
        with key: AsymmetricSecretKey<Self>,
        footer: Data = Data()
    ) throws -> Blob<Signed<Self>> {
        return try sign(Data(string.utf8), with: key, footer: footer)
    }
}

public extension Implementation {
    static func encrypt(
        _ message: String, with key: SymmetricKey<Self>, footer: Data = Data()
    ) -> Blob<Encrypted<Self>>? {
        return encrypt(Data(message.utf8), with: key, footer: footer)
    }

    static func decrypt(
        _ encrypted: Blob<Encrypted<Self>>, with key: SymmetricKey<Self>
    ) -> String? {
        return decrypt(encrypted, with: key)?.utf8String
    }

    static func sign(
        _ string: String,
        with key: AsymmetricSecretKey<Self>,
        footer: Data = Data()
    ) -> Blob<Signed<Self>>? {
        return sign(Data(string.utf8), with: key, footer: footer)
    }

    static func verify(
        _ signedMessage: Blob<Signed<Self>>, with key: AsymmetricPublicKey<Self>
    ) -> String? {
        return verify(signedMessage, with: key)?.utf8String
    }
}
