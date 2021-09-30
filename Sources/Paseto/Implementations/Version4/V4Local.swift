//
//  V2Local.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

extension Version4.Local {
    internal static func encrypt(
        _ package: Package,
        with key: SymmetricKey,
        implicit: BytesRepresentable,
        unitTestNonce: BytesRepresentable?
    ) -> Message<Local> {
        let (message, footer) = (package.content, package.footer)
        let nonceLength = Payload.nonceLength
        
        let nonce: Bytes

        if let given = unitTestNonce?.bytes, given.count == nonceLength {
            nonce = given
        } else {
            nonce = Util.random(length: nonceLength)
        }

        // force unwrap here because we have checked the nonce length
        let (Ek: encKey, Ak: authKey, n2: nonce2) = try! key.split(nonce: nonce)

        let cipherText = XChaCha20.crypto_stream_xor(
            message: message,
            nonce: nonce2,
            secretKey: encKey
        )!

        let header = Header(version: version, purpose: .Local)
        let preAuth = Util.pae([header, nonce, cipherText, footer, implicit])
        
        let tag = sodium.genericHash.hash(
            message: preAuth,
            key: authKey,
            outputLength: Payload.macLength
        )!

        let payload = Payload(nonce: nonce, cipherText: cipherText, mac: tag)

        return Message(payload: payload, footer: footer)
    }

    internal static func encrypt(
        _ data: BytesRepresentable,
        with key: SymmetricKey,
        footer: BytesRepresentable,
        implicit: BytesRepresentable,
        unitTestNonce: BytesRepresentable?
    ) -> Message<Local> {
        return encrypt(
            Package(data, footer: footer),
            with: key,
            implicit: implicit,
            unitTestNonce: unitTestNonce
        )
    }
}

extension Version4.Local: BaseLocal {
    public typealias Local = Version4.Local

    public static func encrypt(
        _ package: Package,
        with key: SymmetricKey
    ) -> Message<Local> {
        return encrypt(package, with: key, implicit: [])
    }

    public static func decrypt(
        _ message: Message<Local>,
        with key: SymmetricKey
    ) throws -> Package {
        return try decrypt(message, with: key, implicit: [])
    }

    public static func encrypt(
        _ package: Package,
        with key: SymmetricKey,
        implicit: BytesRepresentable
    ) -> Message<Local> {
        return encrypt(package, with: key, implicit: implicit, unitTestNonce: nil)
    }

    public static func decrypt(
        _ message: Message<Local>,
        with key: SymmetricKey,
        implicit: BytesRepresentable
    ) throws -> Package {
        let (header, footer) = (message.header, message.footer)

        let nonce      = message.payload.nonce
        let cipherText = message.payload.cipherText
        let givenTag   = message.payload.mac

        let (Ek: encKey, Ak: authKey, n2: nonce2) = try key.split(nonce: nonce)

        let preAuth = Util.pae([header, nonce, cipherText, footer, implicit])

        let expectedTag = sodium.genericHash.hash(
            message: preAuth,
            key: authKey,
            outputLength: Payload.macLength
        )!

        guard Util.equals(expectedTag, givenTag) else {
            throw Exception.badMac("Invalid message authentication code.")
        }

        guard let plainText = XChaCha20.crypto_stream_xor(
            message: cipherText,
            nonce: nonce2,
            secretKey: encKey
        ) else {
            throw Version4.Exception.invalidSignature(
                "The message could not be decrypted."
            )
        }

        return Package(plainText, footer: footer)
    }
}

extension Version4.Local: NonThrowingLocalEncrypt {}

extension Version4.Local {
    enum Exception: Error {
        case badMac(String)
    }
}
