//
//  Version1.swift
//  Paseto
//
//  Created by Aidan Woods on 09/03/2018.
//

import Foundation
import CryptoSwift


public struct Version1 {
    static let keyBytes   = 32
    static let nonceBytes = 32
    static let macBytes   = 48

    internal static func encrypt(
        _ message: Data,
        with key: SymmetricKey<Version1>,
        footer: Data,
        unitTestNonce: Data?
    ) throws -> Blob<Encrypted<Version1>, Version1> {
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

        let payload = Encrypted<Version1>(
            nonce: nonce,
            cipherText: cipherText,
            mac: mac
        )

        return Blob(payload: payload, footer: footer)
    }
}

extension Version1: Implementation {
    public static func encrypt(
        _ message: Data,
        with key: SymmetricKey<Version1>,
        footer: Data
    ) throws -> Blob<Encrypted<Version1>, Version1> {
        return try encrypt(
            message,
            with: key,
            footer: footer,
            unitTestNonce: nil
        )
    }

    public static func decrypt(
        _ encrypted: Blob<Encrypted<Version1>, Version1>,
        with key: SymmetricKey<Version1>
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

    public static func sign(
        _ data: Data,
        with key: AsymmetricSecretKey<Version1>,
        footer: Data
    ) throws -> Blob<Signed<Version1>, Version1> {
        throw Exception.notImplemented("""
            Not implemented.
            Swift's standard library requires at least OSX 10.13 to use the
            RSA that we need. There isn't much value in only implementing
            this for one platform. Alternative solution is sought.
            """
        )
    }

    public static func verify(
        _ signedMessage: Blob<Signed<Version1>, Version1>,
        with key: AsymmetricPublicKey<Version1>
    ) throws -> Data {
        throw Exception.notImplemented("""
            Not implemented.
            Swift's standard library requires at least OSX 10.13 to use the
            RSA that we need. There isn't much value in only implementing
            this for one platform. Alternative solution is sought.
            """
        )
    }
}

extension Version1 {
    static func getNonce(message: Data, preNonce: Data) throws -> Data {
        let hmac = try HMAC(
            key: preNonce.bytes,
            variant: .sha384
        ).authenticate(message.bytes)

        return Data(hmac)[..<32]
    }
}

extension Version1 {
    enum Exception: Error {
        case badMac(String)
        case notImplemented(String)
    }
}

fileprivate extension SymmetricKey where VersionType == Version1 {
    func split(salt: Data) throws -> (Ek: Data, Ak: Data) {
        guard salt.count == 16 else {
            throw Exception.badSalt("Salt must be exactly 16 bytes")
        }

        let salt16 = salt[..<16]

        let encKey = try HKDF(
            password: material.bytes,
            salt: salt16.bytes,
            info: Array("paseto-encryption-key".utf8),
            keyLength: 32,
            variant: .sha384
        ).calculate()

        let authKey = try HKDF(
            password: material.bytes,
            salt: salt16.bytes,
            info: Array("paseto-auth-key-for-aead".utf8),
            keyLength: 32,
            variant: .sha384
        ).calculate()

        return (Ek: Data(encKey), Ak: Data(authKey))
    }
}

extension SymmetricKey {
    enum Exception: Error {
        case badSalt(String)
        case hmacFailure(String)
    }
}
