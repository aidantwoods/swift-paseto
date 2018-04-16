//
//  Version1.swift
//  Paseto
//
//  Created by Aidan Woods on 09/03/2018.
//

import Foundation

public enum Version1 {
    public struct Local {
        static let keyBytes   = 32
        static let nonceBytes = 32
        static let macBytes   = 48

        public struct Payload {
            let nonce: Data
            let cipherText: Data
            let mac: Data
        }

        public struct SymmetricKey {
            public let material: Data

            fileprivate init? (preventDefaultInit: Any) { return nil }
        }
    }
}

extension Version1: Local {
    public typealias SymmetricKey = Local.SymmetricKey

    public static func encrypt(
        _ data: Data,
        with key: SymmetricKey,
        footer: Data
    ) throws -> Message<Local> {
        return try Local.encrypt(data, with: key, footer: footer)
    }

    internal static func encrypt(
        _ message: Data,
        with key: SymmetricKey,
        footer: Data,
        unitTestNonce: Data?
    ) throws -> Message<Local> {
        return try Local.encrypt(
            message,
            with: key,
            footer: footer,
            unitTestNonce: unitTestNonce
        )
    }

    public static func decrypt(
        _ message: Message<Local>,
        with key: SymmetricKey
    ) throws -> Data {
        return try Local.decrypt(message, with: key)
    }
}
