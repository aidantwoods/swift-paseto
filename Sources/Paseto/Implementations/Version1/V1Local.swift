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
        _ package: Package,
        with key: SymmetricKey,
        unitTestNonce: BytesRepresentable?
    ) throws -> Message<Local> {
        let (data, footer) = (package.content, package.footer)
        let nonceLength = Payload.nonceLength

        let preNonce: Bytes

        if let given = unitTestNonce?.bytes, given.count == nonceLength {
            preNonce = given
        } else {
            preNonce = Util.random(length: nonceLength)
        }

        let nonce = try getNonce(message: data, preNonce: preNonce)

        let (Ek: encKey, Ak: authKey) = try key.split(salt: nonce[..<16])

        let cipherText = try AES(
            key: encKey,
            blockMode: CTR(iv: nonce[16...].bytes),
            padding: .noPadding
        ).encrypt(data)

        let header = Header(version: version, purpose: .Local)
        let pae = Util.pae([header, nonce, cipherText, footer])

        let mac = try HMAC(key: authKey, variant: .sha384).authenticate(pae)

        let payload = Payload(nonce: nonce, cipherText: cipherText, mac: mac)

        return Message(payload: payload, footer: footer)
    }

    internal static func encrypt(
        _ data: BytesRepresentable,
        with key: SymmetricKey,
        footer: BytesRepresentable,
        unitTestNonce: BytesRepresentable?
    ) throws -> Message<Local> {
        return try encrypt(
            Package(data, footer: footer),
            with: key,
            unitTestNonce: unitTestNonce
        )
    }
}

extension Version1.Local: BaseLocal {
    public typealias Local = Version1.Local

    public static func encrypt(
        _ package: Package,
        with key: SymmetricKey
    ) throws -> Message<Local> {
        return try encrypt(package, with: key, unitTestNonce: nil)
    }

    public static func decrypt(
        _ message: Message<Local>,
        with key: SymmetricKey
    ) throws -> Package {
        let (header, footer) = (message.header, message.footer)

        let nonce      = message.payload.nonce
        let cipherText = message.payload.cipherText
        let mac        = message.payload.mac

        let (Ek: encKey, Ak: authKey) = try key.split(salt: nonce[..<16])

        let pae = Util.pae([header, nonce, cipherText, footer])

        let expectedMac = try HMAC(key: authKey, variant: .sha384).authenticate(pae)

        guard Util.equals(expectedMac, mac) else {
            throw Exception.badMac("Invalid message authentication code.")
        }

        let plainText = try AES(
            key: encKey,
            blockMode: CTR(iv: nonce[16...].bytes),
            padding: .noPadding
        ).decrypt(cipherText)

        return Package(plainText, footer: footer)
    }
}

extension Version1.Local {
    static func getNonce(message: Bytes, preNonce: Bytes) throws -> Bytes {
        let hmac = try HMAC(key: preNonce, variant: .sha384).authenticate(message)

        return hmac[..<32].bytes
    }
}

extension Version1.Local {
    enum Exception: Error {
        case badMac(String)
        case notImplemented(String)
    }
}
