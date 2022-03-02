import Foundation

extension Version4.Public: BasePublic {
    public typealias Public = Version4.Public

    public static func sign(
        _ package: Package,
        with key: AsymmetricSecretKey
    ) -> Message<Public> {
        return sign(package, with: key, implicit: [])
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
    ) -> Message<Public> {
        let (data, footer) = (package.content, package.footer)

        let header = Header(version: version, purpose: .Public)

        let signature = Sign.signature(
            message: Util.pae([header, data, footer, implicit]),
            secretKey: key.material
        )!

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

        guard Sign.verify(
            message: Util.pae([header, payload.message, footer, implicit]),
            publicKey: key.material,
            signature: payload.signature
        ) else {
            throw Version4.Exception.invalidSignature(
                "Invalid signature for this message."
            )
        }

        return Package(payload.message, footer: footer)
    }
}

extension Version4.Public: NonThrowingPublicSign {}
