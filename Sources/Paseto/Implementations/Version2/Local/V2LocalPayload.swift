//
//  V2LocalPayload.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

extension Version2.Local: Implementation {
    public struct Payload {
        let nonce: Data
        let cipherText: Data
    }
}

extension Version2.Local.Payload: Paseto.Payload {
    public var asData: Data { return nonce + cipherText }

    public init? (data: Data) {
        let nonceLen = Int(Aead.nonceBytes)

        guard data.count > nonceLen else { return nil }

        self.init(
            nonce:      data[..<nonceLen],
            cipherText: data[nonceLen...]
        )
    }
}
