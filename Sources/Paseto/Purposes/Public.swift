//
//  Public.swift
//  Paseto
//
//  Created by Aidan Woods on 11/04/2018.
//

import Foundation

public protocol Public {
    associatedtype SecretKey: AsymmetricSecretKey
    associatedtype PublicKey: AsymmetricPublicKey where
        PublicKey == SecretKey.Module.PublicKey

    associatedtype Public: BasePublic where SecretKey == Public.SecretKey

    static func sign(_: Package, with: SecretKey) throws -> Message<Public>

    static func verify(_: Message<Public>, with: PublicKey) throws -> Package
}

public extension Public {
    static func sign(
        _ data: Data,
        with key: SecretKey,
        footer: Data = Data()
    ) throws -> Message<Public> {
        return try sign(Package(data: data, footer: footer), with: key)
    }

    static func sign(
        _ string: String,
        with key: SecretKey,
        footer: Data = Data()
    ) throws -> Message<Public> {
        return try sign(Data(string.utf8), with: key, footer: footer)
    }
}

public extension Public {
    static func verify(
        _ message: Message<Public>,
        with key: PublicKey
    ) -> String? {
        return (try? verify(message, with: key))?.content.utf8String
    }
}
