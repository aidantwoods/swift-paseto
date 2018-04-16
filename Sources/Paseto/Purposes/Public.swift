//
//  Public.swift
//  Paseto
//
//  Created by Aidan Woods on 11/04/2018.
//

import Foundation

public protocol Public {
    associatedtype AsymmetricSecretKey: Paseto.AsymmetricSecretKey
    associatedtype AsymmetricPublicKey: Paseto.AsymmetricPublicKey where
        AsymmetricPublicKey == AsymmetricSecretKey.ImplementationType.AsymmetricPublicKey

    associatedtype Public: Paseto.Public & Implementation where Public.Public == Public

    static func sign(_: Data, with: AsymmetricSecretKey, footer: Data)
        throws -> Message<Public>

    static func verify(_: Message<Public>, with: AsymmetricPublicKey)
        throws -> Data
}

public extension Public {
    static func sign(_ data: Data, with key: AsymmetricSecretKey)
        throws -> Message<Public>
    { return try sign(data, with: key, footer: Data()) }
}

public extension Public {
    static func sign(_ data: Data, with key: AsymmetricSecretKey, footer: Data = Data())
        -> Message<Public>?
    { return try? sign(data, with: key, footer: footer) }

    static func verify(_ message: Message<Public>, with key: AsymmetricPublicKey)
        -> Data?
    { return try? verify(message, with: key) }
}

public extension Public {
    static func sign(_ string: String, with key: AsymmetricSecretKey, footer: Data = Data())
        throws -> Message<Public>
    { return try sign(Data(string.utf8), with: key, footer: footer) }
}

public extension Public {
    static func sign(_ string: String, with key: AsymmetricSecretKey, footer: Data = Data())
        -> Message<Public>?
    { return sign(Data(string.utf8), with: key, footer: footer) }

    static func verify(_ message: Message<Public>, with key: AsymmetricPublicKey)
        -> String?
    { return verify(message, with: key)?.utf8String }
}
