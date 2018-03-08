//
//  EncryptedPayload.swift
//  Paseto
//
//  Created by Aidan Woods on 08/03/2018.
//

import Foundation

public struct Encrypted {
    let nonce: Data
    let cipherText: Data

    init (nonce: Data, cipherText: Data) {
        self.nonce      = nonce
        self.cipherText = cipherText
    }
}

extension Encrypted: Payload {
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
