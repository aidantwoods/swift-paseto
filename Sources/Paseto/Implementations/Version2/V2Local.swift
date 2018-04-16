//
//  V2Local.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

extension Version2.Local {
    internal static func encrypt(
        _ message: Data,
        with key: SymmetricKey,
        footer: Data,
        unitTestNonce: Data?
    ) -> Message<Local> {
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
}

extension Version2.Local: BaseLocal {
    public typealias Local = Version2.Local

    public static func encrypt(
        _ data: Data,
        with key: SymmetricKey,
        footer: Data
    ) -> Message<Local> {
        return encrypt(data, with: key, footer: footer, unitTestNonce: nil)
    }

    public static func decrypt(
        _ encrypted: Message<Local>,
        with key: SymmetricKey
    ) throws -> Data {
        let (header, footer) = (encrypted.header, encrypted.footer)

        let nonce      = encrypted.payload.nonce
        let cipherText = encrypted.payload.cipherText

        guard let message = Aead.xchacha20poly1305_ietf_decrypt(
            cipherText: cipherText,
            additionalData: Util.pae([header.asData, nonce, footer]),
            nonce: nonce,
            secretKey: key.material
        ) else {
            throw Version2.Exception.invalidSignature(
                "The message could not be decrypted."
            )
        }

        return message
    }
}

// non throwing/optional implementations are available for Version 2
public extension Version2.Local {
    static func encrypt(
        _ message: String,
        with key: SymmetricKey,
        footer: Data = Data()
    ) -> Message<Local> {
        return encrypt(Data(message.utf8), with: key, footer: footer)
    }
}
