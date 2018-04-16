//
//  V1LocalPayload.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

extension Version1.Local: Implementation {}

extension Version1.Local.Payload: Paseto.Payload {
    public var asData: Data { return nonce + cipherText + mac }

    public init? (data: Data) {
        let nonceLen = Version1.Local.nonceBytes
        let macLen   = Version1.Local.macBytes

        guard data.count > nonceLen + macLen else { return nil }

        let macOffset = data.count - macLen

        self.init(
            nonce:      data[..<nonceLen],
            cipherText: data[nonceLen..<macOffset],
            mac:        data[macOffset...]
        )
    }
}
