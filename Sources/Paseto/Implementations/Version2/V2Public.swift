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
        _ data: Data,
        with key: AsymmetricSecretKey,
        footer: Data
    ) -> Message<Public> {
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
        _ signedMessage: Message<Public>,
        with key: AsymmetricPublicKey
    ) throws -> Data {
        let (header, footer) = (signedMessage.header, signedMessage.footer)

        let payload = signedMessage.payload

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

        return payload.message
    }
}

public extension Version2.Public {
    static func sign(
        _ string: String,
        with key: AsymmetricSecretKey,
        footer: Data = Data()
    ) -> Message<Public> {
        return sign(Data(string.utf8), with: key, footer: footer)
    }
}
