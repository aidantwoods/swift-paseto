//
//  Public.swift
//  Paseto_V2
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation
@testable import Paseto_Core

extension Version2.Public: BasePublic {
    public typealias Public = Version2.Public

    public static func sign(
        _ package: Package,
        with key: AsymmetricSecretKey
    ) -> Message<Public> {
        let (data, footer) = (package.content, package.footer)

        let header = Header(version: version, purpose: .Public)

        let signature = Sign.signature(
            message: Util.pae([header.asData, data, footer]),
            secretKey: key.material
        )!

        let payload = Payload(
            message: data,
            signature: signature
        )

        return Message(payload: payload, footer: footer)
    }

    public static func verify(
        _ message: Message<Public>,
        with key: AsymmetricPublicKey
    ) throws -> Package {
        let (header, footer) = (message.header, message.footer)

        let payload = message.payload

        let isValid = Sign.verify(
            message: Util.pae([header.asData, payload.message, footer]),
            publicKey: key.material,
            signature: payload.signature
        )

        guard isValid else {
            throw Version2.Exception.invalidSignature(
                "Invalid signature for this message."
            )
        }

        return Package(payload.message, footer: footer)
    }
}

extension Version2.Public: NonThrowingPublicSign {}
