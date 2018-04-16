//
//  Version2.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public enum Version2 {
    public struct Local {}
    public struct Public {
        public struct Payload {
            let message: Data
            let signature: Data
        }

        public struct AsymmetricSecretKey {
            public let material: Data

            let secretBytes  = Sign.SecretKeyBytes
            let seedBytes    = Sign.SeedBytes
            let keypairBytes = 96

            fileprivate init? (preventDefaultInit: Any) { return nil }
        }

        public struct AsymmetricPublicKey {
            public let material: Data

            fileprivate init? (preventDefaultInit: Any) { return nil }
        }
    }
}

extension Version2 {
    public enum Exception: Error {
        case invalidSignature(String)
    }
}

extension Version2: Local {
    public typealias SymmetricKey = Local.SymmetricKey

    public static func encrypt(
        _ data: Data, with key: SymmetricKey, footer: Data = Data()
    ) -> Message<Local> {
        return Local.encrypt(data, with: key, footer: footer)
    }

    internal static func encrypt(
        _ message: Data,
        with key: SymmetricKey,
        footer: Data,
        unitTestNonce: Data?
    ) -> Message<Local> {
        return Local.encrypt(message, with: key, footer: footer, unitTestNonce: unitTestNonce)
    }

    public static func decrypt(
        _ message: Message<Local>, with key: SymmetricKey
    ) throws -> Data {
        return try Local.decrypt(message, with: key)
    }
}

// non throwing/optional implementations are available for Version 2
public extension Version2 {
    static func encrypt(
        _ message: String,
        with key: SymmetricKey,
        footer: Data = Data()
    ) -> Message<Local> {
        return Local.encrypt(message, with: key, footer: footer)
    }
}

extension Version2: Public {
    public typealias AsymmetricSecretKey = Public.AsymmetricSecretKey
    public typealias AsymmetricPublicKey = Public.AsymmetricPublicKey

    public static func sign(
        _ data: Data, with key: AsymmetricSecretKey, footer: Data = Data()
    ) -> Message<Public> {
        return Public.sign(data, with: key, footer: footer)
    }

    public static func verify(
        _ message: Message<Public>, with key: AsymmetricPublicKey
    ) throws -> Data
    {
        return try Public.verify(message, with: key)
    }
}

public extension Version2 {
    static func sign(
        _ string: String,
        with key: AsymmetricSecretKey,
        footer: Data = Data()
    ) -> Message<Public> {
        return Public.sign(string, with: key, footer: footer)
    }
}
