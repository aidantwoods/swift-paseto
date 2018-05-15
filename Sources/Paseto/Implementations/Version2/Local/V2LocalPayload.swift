//
//  V2LocalPayload.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

extension Version2.Local: Module {
    public struct Payload {
        let nonce: Bytes
        let cipherText: Bytes
    }
}

extension Version2.Local.Payload: Paseto.Payload {
    public var bytes: Bytes { return nonce + cipherText }

    public init? (bytes: Bytes) {
        let nonceLen = Int(Aead.nonceBytes)

        guard bytes.count > nonceLen else { return nil }

        self.init(
            nonce:      bytes[..<nonceLen].bytes,
            cipherText: bytes[nonceLen...].bytes
        )
    }
}
