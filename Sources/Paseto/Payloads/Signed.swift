//
//  SignedPayload.swift
//  Paseto
//
//  Created by Aidan Woods on 07/03/2018.
//

import Foundation

public struct Signed {
    let version: Version
    let message: Data
    let signature: Data

    init (version: Version, message: Data, signature: Data) {
        self.version   = version
        self.message   = message
        self.signature = signature
    }
}

extension Signed: Payload {
    public var asData: Data {
        switch version {
        case .v2: return message + signature
        }
    }

    public init? (version: Version, data: Data) {
        switch version {
        case .v2:
            let signatureOffset = data.count - Sign.Bytes

            guard signatureOffset > 0 else { return nil }

            self.init(
                version:   version,
                message:   data[..<signatureOffset],
                signature: data[signatureOffset...]
            )
        }
    }
}
