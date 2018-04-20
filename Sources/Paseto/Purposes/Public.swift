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
        AsymmetricPublicKey == AsymmetricSecretKey.Module.AsymmetricPublicKey

    associatedtype Public: BasePublic where
        AsymmetricSecretKey == Public.AsymmetricSecretKey

    static func sign(_: Package, with: AsymmetricSecretKey) throws -> Message<Public>

    static func verify(_: Message<Public>, with: AsymmetricPublicKey) throws -> Package
}

public extension Public {
    static func sign(
        _ data: Data,
        with key: AsymmetricSecretKey,
        footer: Data = Data()
    ) throws -> Message<Public> {
        return try sign(Package(data: data, footer: footer), with: key)
    }

    static func sign(
        _ string: String,
        with key: AsymmetricSecretKey,
        footer: Data = Data()
    ) throws -> Message<Public> {
        return try sign(Data(string.utf8), with: key, footer: footer)
    }
}
