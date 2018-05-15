//
//  V1LocalPayload.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

extension Version1.Local: Module {
    public struct Payload {
        static let nonceLength = 32
        static let macLength   = 48

        let nonce: Bytes
        let cipherText: Bytes
        let mac: Bytes
    }
}

extension Version1.Local.Payload: Paseto.Payload {
    public var bytes: Bytes { return nonce + cipherText + mac }

    public init? (bytes: Bytes) {
        let nonceLen = Version1.Local.Payload.nonceLength
        let macLen   = Version1.Local.Payload.macLength

        guard bytes.count > nonceLen + macLen else { return nil }

        let macOffset = bytes.count - macLen

        self.init(
            nonce:      bytes[..<nonceLen].bytes,
            cipherText: bytes[nonceLen..<macOffset].bytes,
            mac:        bytes[macOffset...].bytes
        )
    }
}
