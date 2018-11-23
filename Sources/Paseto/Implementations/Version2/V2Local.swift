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
        unitTestNonce: BytesRepresentable?
    ) -> Message<Local> {
        let (message, footer) = (package.content, package.footer)

        let nonceBytes = Aead.nonceBytes

        let preNonce: Bytes

        if let given = unitTestNonce?.bytes, given.count == nonceBytes {
            preNonce = given
        } else {
            preNonce = Util.random(length: nonceBytes)
        }

        let nonce = sodium.genericHash.hash(
            message: message,
            key: preNonce,
            outputLength: nonceBytes
        )!

        let header = Header(version: version, purpose: .Local)

        let cipherText = Aead.xchacha20poly1305_ietf_encrypt(
            message: message,
            additionalData: Util.pae([header, nonce, footer]),
            nonce: nonce,
            secretKey: key.material
        )!

        let payload = Payload(nonce: nonce, cipherText: cipherText)

        return Message(payload: payload, footer: footer)
    }

    internal static func encrypt(
        _ data: BytesRepresentable,
        with key: SymmetricKey,
        footer: BytesRepresentable,
        unitTestNonce: BytesRepresentable?
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
            authenticatedCipherText: cipherText,
            additionalData: Util.pae([header, nonce, footer]),
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
