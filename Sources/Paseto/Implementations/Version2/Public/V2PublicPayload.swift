//
//  V2PublicPayload.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

extension Version2.Public: Module {
    public struct Payload {
        static let signatureLength = Sign.Bytes

        let message: Bytes
        let signature: Bytes
    }
}

extension Version2.Public.Payload: Paseto.Payload {
    public var bytes: Bytes { return message + signature }

    public init? (bytes: Bytes) {
        let signatureOffset = bytes.count - Version2.Public.Payload.signatureLength

        guard signatureOffset > 0 else { return nil }

        self.init(
            message:   bytes[..<signatureOffset].bytes,
            signature: bytes[signatureOffset...].bytes
        )
    }
}
