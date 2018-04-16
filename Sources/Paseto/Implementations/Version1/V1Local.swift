//
//  V1Local.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation
import CryptoSwift

extension Version1.Local {
    internal static func encrypt(
        _ message: Data,
        with key: SymmetricKey,
        footer: Data,
        unitTestNonce: Data?
    ) throws -> Message<Local> {
        let preNonce: Data

        if case let .some(given) = unitTestNonce, given.count == nonceBytes {
            preNonce = given
        } else {
            preNonce = sodium.randomBytes.buf(length: nonceBytes)!
        }

        let nonce = try getNonce(message: message, preNonce: preNonce)

        let (Ek: encKey, Ak: authKey) = try key.split(salt: nonce[..<16])

        let cipherText = Data(
            try AES(
                key: encKey.bytes,
                blockMode: .CTR(iv: nonce[16...].bytes),
                padding: .noPadding
                ).encrypt(message.bytes)
        )

        let header = Header(version: version, purpose: .Local)
        let pae = Util.pae([header.asData, nonce, cipherText, footer])

        let mac = Data(
            try HMAC(
                key: authKey.bytes,
                variant: .sha384
                ).authenticate(pae.bytes)
        )

        let payload = Payload(
            nonce: nonce,
            cipherText: cipherText,
            mac: mac
        )

        return Message(payload: payload, footer: footer)
    }
}

extension Version1.Local: Paseto.Local {
    public typealias Local = Version1.Local

    public static func encrypt(
        _ data: Data,
        with key: SymmetricKey,
        footer: Data
    ) throws -> Message<Local> {
        return try encrypt(
            data,
            with: key,
            footer: footer,
            unitTestNonce: nil
        )
    }

    public static func decrypt(
        _ encrypted: Message<Local>,
        with key: SymmetricKey
    ) throws -> Data {
        let (header, footer) = (encrypted.header, encrypted.footer)

        let nonce      = encrypted.payload.nonce
        let cipherText = encrypted.payload.cipherText
        let mac        = encrypted.payload.mac

        let (Ek: encKey, Ak: authKey) = try key.split(salt: nonce[..<16])

        let pae = Util.pae([header.asData, nonce, cipherText, footer])

        let expectedMac = Data(
            try HMAC(
                key: authKey.bytes,
                variant: .sha384
            ).authenticate(pae.bytes)
        )

        guard sodium.utils.equals(expectedMac, mac) else {
            throw Exception.badMac("Invalid message authentication code.")
        }

        let plainText = Data(
            try AES(
                key: encKey.bytes,
                blockMode: .CTR(iv: nonce[16...].bytes),
                padding: .noPadding
            ).decrypt(cipherText.bytes)
        )

        return plainText
    }
}

extension Version1.Local {
    static func getNonce(message: Data, preNonce: Data) throws -> Data {
        let hmac = try HMAC(
            key: preNonce.bytes,
            variant: .sha384
            ).authenticate(message.bytes)

        return Data(hmac)[..<32]
    }
}

extension Version1.Local {
    enum Exception: Error {
        case badMac(String)
        case notImplemented(String)
    }
}
