//
//  V2Local.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

extension Version2.Local {
    internal static func encrypt(
        _ package: Package,
        with key: SymmetricKey,
        unitTestNonce: Data?
    ) -> Message<Local> {
        let (message, footer) = (package.content, package.footer)

        let nonceBytes = Int(Aead.nonceBytes)

        let preNonce: Data

        if case let .some(given) = unitTestNonce, given.count == nonceBytes {
            preNonce = given
        } else {
            preNonce = sodium.randomBytes.buf(length: nonceBytes)!
        }

        let nonce = sodium.genericHash.hash(
            message: message,
            key: preNonce,
            outputLength: nonceBytes
        )!

        let header = Header(version: version, purpose: .Local)

        let cipherText = Aead.xchacha20poly1305_ietf_encrypt(
            message: message,
            additionalData: Util.pae([header.asData, nonce, footer]),
            nonce: nonce,
            secretKey: key.material
        )!

        let payload = Payload(
            nonce: nonce,
            cipherText: cipherText
        )

        return Message(payload: payload, footer: footer)
    }

    internal static func encrypt(
        _ data: Data,
        with key: SymmetricKey,
        footer: Data,
        unitTestNonce: Data?
    ) -> Message<Local> {
        return encrypt(
            Package(data, footer: footer),
            with: key,
            unitTestNonce: unitTestNonce
        )
    }
}

extension Version2.Local: BaseLocal {
    public typealias Local = Version2.Local

    public static func encrypt(
        _ package: Package,
        with key: SymmetricKey
    ) -> Message<Local> {
        return encrypt(package, with: key, unitTestNonce: nil)
    }

    public static func decrypt(
        _ message: Message<Local>,
        with key: SymmetricKey
    ) throws -> Package {
        let (header, footer) = (message.header, message.footer)

        let nonce      = message.payload.nonce
        let cipherText = message.payload.cipherText

        guard let plainText = Aead.xchacha20poly1305_ietf_decrypt(
            cipherText: cipherText,
            additionalData: Util.pae([header.asData, nonce, footer]),
            nonce: nonce,
            secretKey: key.material
        ) else {
            throw Version2.Exception.invalidSignature(
                "The message could not be decrypted."
            )
        }

        return Package(plainText, footer: footer)
    }
}

extension Version2.Local: NonThrowingLocalEncrypt {}
