import Foundation
import CryptoSwift

extension Version3.Local {
    internal static func encrypt(
        _ package: Package,
        with key: SymmetricKey,
        implicit: BytesRepresentable,
        unitTestNonce: BytesRepresentable?
    ) throws -> Message<Local> {
        let (data, footer) = (package.content, package.footer)
        let nonceLength = Payload.nonceLength

        let nonce: Bytes

        if let given = unitTestNonce?.bytes, given.count == nonceLength {
            nonce = given
        } else {
            nonce = Util.random(length: nonceLength)
        }

        let (Ek: encKey, Ak: authKey, n2: nonce2) = try key.split(nonce: nonce)

        let cipherText = try AES(
            key: encKey,
            blockMode: CTR(iv: nonce2),
            padding: .noPadding
        ).encrypt(data)

        let header = Header(version: version, purpose: .Local)
        let preAuth = Util.pae([header, nonce, cipherText, footer, implicit.bytes])

        let tag = try HMAC(key: authKey, variant: .sha384).authenticate(preAuth)

        let payload = Payload(nonce: nonce, cipherText: cipherText, mac: tag)

        return Message(payload: payload, footer: footer)
    }

    internal static func encrypt(
        _ data: BytesRepresentable,
        with key: SymmetricKey,
        footer: BytesRepresentable,
        implicit: BytesRepresentable,
        unitTestNonce: BytesRepresentable?
    ) throws -> Message<Local> {
        return try encrypt(
            Package(data, footer: footer),
            with: key,
            implicit: implicit,
            unitTestNonce: unitTestNonce
        )
    }
}

extension Version3.Local: BaseLocal {
    public typealias Local = Version3.Local
    
    public static func encrypt(
        _ package: Package,
        with key: SymmetricKey
    ) throws -> Message<Local> {
        return try encrypt(package, with: key, implicit: [])
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
    ) throws -> Message<Local> {
        return try encrypt(package, with: key, implicit: implicit, unitTestNonce: nil)
    }

    public static func decrypt(
        _ message: Message<Local>,
        with key: SymmetricKey,
        implicit: BytesRepresentable
    ) throws -> Package {
        let (header, footer) = (message.header, message.footer)

        let nonce      = message.payload.nonce
        let cipherText = message.payload.cipherText
        let givenMac   = message.payload.mac

        let (Ek: encKey, Ak: authKey, n2: nonce2) = try key.split(nonce: nonce)

        let preAuth = Util.pae([header, nonce, cipherText, footer, implicit.bytes])

        let expectedMac = try HMAC(key: authKey, variant: .sha384).authenticate(preAuth)

        guard Util.equals(expectedMac, givenMac) else {
            throw Exception.badMac("Invalid message authentication code.")
        }

        let plainText = try AES(
            key: encKey,
            blockMode: CTR(iv: nonce2),
            padding: .noPadding
        ).decrypt(cipherText)

        return Package(plainText, footer: footer)
    }
}

extension Version3.Local {
    enum Exception: Error {
        case badMac(String)
        case notImplemented(String)
    }
}
