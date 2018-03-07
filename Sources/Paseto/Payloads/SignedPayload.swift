//
//  SignedPayload.swift
//  Paseto
//
//  Created by Aidan Woods on 07/03/2018.
//

import Foundation

public struct SignedPayload {
    let signature: Data
    let message: Data

    init (message: Data, signature: Data) {
        self.message   = message
        self.signature = signature
    }
}

extension SignedPayload: Payload {
    public var asData: Data { return message + signature }

    public init? (data: Data) {
        let signatureOffset = data.count - Sign.Bytes

        guard signatureOffset > 0 else { return nil }

        self.init(
            message:   data[..<signatureOffset],
            signature: data[signatureOffset...]
        )
    }
}
