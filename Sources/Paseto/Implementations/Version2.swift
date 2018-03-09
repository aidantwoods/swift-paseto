//
//  Version2.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public struct Version2: Implementation {
    public static var version: Version { return .v2 }

    internal static func encrypt(
        _ message: Data,
        with key: SymmetricKey<Version2>,
        footer: Data,
        nonce unitTestNonce: Data?
    ) -> Blob<Encrypted> {
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

        let payload = Encrypted(nonce: nonce, cipherText: cipherText)

        return Blob(header: header, payload: payload, footer: footer)
    }

    public static func encrypt(
        _ message: Data, with key: SymmetricKey<Version2>, footer: Data
    ) -> Blob<Encrypted> {
        return encrypt(message, with: key, footer: footer, nonce: nil)
    }

    public static func decrypt(
        _ encrypted: Blob<Encrypted>, with key: SymmetricKey<Version2>
    ) throws -> Data {
        let header = encrypted.header
        let footer = encrypted.footer

        guard header == Header(version: version, purpose: .Local) else {
            throw Exception.badHeader("Bad message header.")
        }

        let nonce      = encrypted.payload.nonce
        let cipherText = encrypted.payload.cipherText

        guard let message = Aead.xchacha20poly1305_ietf_decrypt(
            cipherText: cipherText,
            additionalData: Util.pae([header.asData, nonce, footer]),
            nonce: nonce,
            secretKey: key.material
        ) else {
            throw Exception.invalidSignature(
                "The message could not be decrypted."
            )
        }

        return message
    }

    public static func sign(
        _ data: Data, with key: AsymmetricSecretKey<Version2>, footer: Data
    ) -> Blob<Signed> {
        let header = Header(version: version, purpose: .Public)

        let signature = Sign.signature(
            message: Util.pae([header.asData, data, footer]),
            secretKey: key.material
        )!

        let payload = Signed(message: data, signature: signature)

        return Blob(header: header, payload: payload, footer: footer)
    }

    public static func verify(
        _ signedMessage: Blob<Signed>, with key: AsymmetricPublicKey<Version2>
    ) throws -> Data {
        let header = signedMessage.header
        let footer = signedMessage.footer

        guard header == Header(version: version, purpose: .Public) else {
            throw Exception.badHeader("Bad message header.")
        }

        let payload = signedMessage.payload

        let isValid = Sign.verify(
            message: Util.pae([header.asData, payload.message, footer]),
            publicKey: key.material,
            signature: payload.signature
        )

        guard isValid else {
            throw Exception.invalidSignature(
                "Invalid signature for this message."
            )
        }

        return payload.message
    }
}

extension Version2 {
    public enum Exception: Error {
        case badHeader(String)
        case invalidSignature(String)
        case invalidMessage(String)
    }
}
