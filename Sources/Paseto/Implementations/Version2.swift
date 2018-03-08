//
//  Version2.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public struct Version2: Implementation {
    public static var version: Version { return .v2 }

    public static func encrypt(
        _ message: Data, with key: SymmetricKey, footer: Data
    ) -> Blob<EncryptedPayload> {
        let nonceBytes = Int(Aead.nonceBytes)
        let preNonce = sodium.randomBytes.buf(length: nonceBytes)!

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

        let payload = EncryptedPayload(nonce: nonce, cipherText: cipherText)

        return Blob(header: header, payload: payload, footer: footer)
    }

    public static func decrypt(
        _ encrypted: Blob<EncryptedPayload>,
        with key: SymmetricKey,
        footer: Data
    ) throws -> Data {
        let header = encrypted.header

        guard header == Header(version: version, purpose: .Local) else {
            throw Exception.badHeader("Bad message header.")
        }
        guard footer == encrypted.footer else {
            throw Exception.badFooter("Invalid message footer.")
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
        _ data: Data, with key: AsymmetricSecretKey, footer: Data
    ) -> Blob<SignedPayload> {
        let header = Header(version: version, purpose: .Public)

        let signature = Sign.signature(
            message: Util.pae([header.asData, data, footer]),
            secretKey: key.material
        )!

        let payload = SignedPayload(message: data, signature: signature)

        return Blob(header: header, payload: payload, footer: footer)
    }

    public static func verify(
        _ signedMessage: Blob<SignedPayload>,
        with key: AsymmetricPublicKey,
        footer: Data
    ) throws -> Data {
        let header = signedMessage.header

        guard header == Header(version: version, purpose: .Public) else {
            throw Exception.badHeader("Bad message header.")
        }
        guard footer == signedMessage.footer else {
            throw Exception.badFooter("Invalid message footer.")
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
        case badFooter(String)
        case invalidSignature(String)
        case invalidMessage(String)
    }
}
