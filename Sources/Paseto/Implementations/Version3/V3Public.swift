import Foundation
import CryptoKit

extension Version3.Public: BasePublic {
    public typealias Public = Version3.Public

    public static func sign(
        _ package: Package,
        with key: AsymmetricSecretKey
    ) throws -> Message<Public> {
        return try sign(package, with: key, implicit: [])
    }

    public static func verify(
        _ message: Message<Public>,
        with key: AsymmetricPublicKey
    ) throws -> Package {
        return try verify(message, with: key, implicit: [])
    }

    public static func sign(
        _ package: Package,
        with key: AsymmetricSecretKey,
        implicit: BytesRepresentable = []
    ) throws -> Message<Public> {
        let (data, footer) = (package.content, package.footer)

        let header = Header(version: version, purpose: .Public)

        let compressedPubKey = key.publicKey.material

        let m2 = Util.pae([compressedPubKey, header, data, footer, implicit])

        let signature = try key.key.signature(for: m2).rawRepresentation.bytes

        let payload = Payload(message: data, signature: signature)

        return Message(payload: payload, footer: footer)
    }

    public static func verify(
        _ message: Message<Public>,
        with key: AsymmetricPublicKey,
        implicit: BytesRepresentable = []
    ) throws -> Package {
        let (header, footer) = (message.header, message.footer)

        let payload = message.payload
        let data = payload.message
        let sig = try P384.Signing.ECDSASignature(rawRepresentation: payload.signature)

        let compressedPubKey = key.material

        let m2 = Util.pae([compressedPubKey, header, data, footer, implicit])

        guard key.key.isValidSignature(sig, for: Data(m2)) else {
            throw Version3.Exception.invalidSignature(
                "Invalid signature for this message."
            )
        }

        return Package(payload.message, footer: footer)
    }
}
