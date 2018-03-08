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
    ) -> Blob<Encrypted>

    static func decrypt(
        _ encrypted: Blob<Encrypted>,
        with key: SymmetricKey<Self>,
        footer: Data
    ) throws -> Data

    static func sign(
        _ data: Data, with key: AsymmetricSecretKey<Self>, footer: Data
    ) -> Blob<Signed>

    static func verify(
        _ signedMessage: Blob<Signed>,
        with key: AsymmetricPublicKey<Self>,
        footer: Data
    ) throws -> Data
}

public extension Implementation {
    static func encrypt(
        _ message: Data, with key: SymmetricKey<Self>
    ) -> Blob<Encrypted> {
        return encrypt(message, with: key, footer: Data())
    }

    static func decrypt(
        _ encrypted: Blob<Encrypted>, with key: SymmetricKey<Self>
    ) throws -> Data {
        return try decrypt(encrypted, with: key, footer: Data())
    }

    static func sign(
        _ data: Data, with key: AsymmetricSecretKey<Self>
    ) -> Blob<Signed> {
        return sign(data, with: key, footer: Data())
    }

    static func verify(
        _ signedMessage: Blob<Signed>,
        with key: AsymmetricPublicKey<Self>
    ) throws -> Data {
        return try verify(signedMessage, with: key, footer: Data())
    }
}

public extension Implementation {
    static func decrypt(
        _ encrypted: Blob<Encrypted>,
        with key: SymmetricKey<Self>,
        footer: Data = Data()
    ) -> Data? {
        return try? decrypt(encrypted, with: key, footer: footer)
    }

    static func verify(
        _ signedMessage: Blob<Signed>,
        with key: AsymmetricPublicKey<Self>,
        footer: Data = Data()
    ) -> Data? {
        return try? verify(signedMessage, with: key, footer: footer)
    }
}

public extension Implementation {
    static func encrypt(
        _ message: String, with key: SymmetricKey<Self>, footer: Data = Data()
    ) -> Blob<Encrypted> {
        return encrypt(Data(message.utf8), with: key, footer: footer)
    }

    static func decrypt(
        _ encrypted: Blob<Encrypted>,
        with key: SymmetricKey<Self>,
        footer: Data = Data()
    ) -> String? {
        return decrypt(encrypted, with: key, footer: footer)?.utf8String
    }

    static func sign(
        _ string: String,
        with key: AsymmetricSecretKey<Self>,
        footer: Data = Data()
    ) -> Blob<Signed> {
        return sign(Data(string.utf8), with: key, footer: footer)
    }

    static func verify(
        _ signedMessage: Blob<Signed>,
        with key: AsymmetricPublicKey<Self>,
        footer: Data = Data()
    ) -> String? {
        return verify(signedMessage, with: key, footer: footer)?.utf8String
    }
}
