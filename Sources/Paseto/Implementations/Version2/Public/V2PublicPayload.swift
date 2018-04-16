//
//  V2PublicPayload.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

extension Version2.Public: Implementation {}

extension Version2.Public.Payload: Paseto.Payload {
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
