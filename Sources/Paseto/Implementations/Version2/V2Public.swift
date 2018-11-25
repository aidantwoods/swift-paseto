//
//  V2Public.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

extension Version2.Public: BasePublic {
    public typealias Public = Version2.Public

    public static func sign(
        _ package: Package,
        with key: AsymmetricSecretKey
    ) -> Message<Public> {
        let (data, footer) = (package.content, package.footer)

        let header = Header(version: version, purpose: .Public)

        let signature = Sign.signature(
            message: Util.pae([header, data, footer]),
            secretKey: key.material
        )!

        let payload = Payload(message: data, signature: signature)

        return Message(payload: payload, footer: footer)
    }

    public static func verify(
        _ message: Message<Public>,
        with key: AsymmetricPublicKey
    ) throws -> Package {
        let (header, footer) = (message.header, message.footer)

        let payload = message.payload

        guard Sign.verify(
            message: Util.pae([header, payload.message, footer]),
            publicKey: key.material,
            signature: payload.signature
        ) else {
            throw Version2.Exception.invalidSignature(
                "Invalid signature for this message."
            )
        }

        return Package(payload.message, footer: footer)
    }
}

extension Version2.Public: NonThrowingPublicSign {}
