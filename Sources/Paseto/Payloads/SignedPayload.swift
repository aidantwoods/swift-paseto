//
//  SignedPayload.swift
//  Paseto
//
//  Created by Aidan Woods on 07/03/2018.
//

import Foundation

public struct SignedPayload: Payload {
    let signature: Data
    let message: Data
    static let signBytes: Int = Sign.Bytes

    public init? (data: Data) {
        let signatureOffset = data.count - SignedPayload.signBytes

        guard signatureOffset > 0 else { return nil }

        self.init(
            message:   data[..<signatureOffset],
            signature: data[signatureOffset...]
        )
    }

    init (message: Data, signature: Data) {
        self.message   = message
        self.signature = signature
    }

    public var asData: Data { return message + signature }
}
