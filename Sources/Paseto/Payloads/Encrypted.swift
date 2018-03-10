//
//  EncryptedPayload.swift
//  Paseto
//
//  Created by Aidan Woods on 08/03/2018.
//

import Foundation

public struct Encrypted {
    let version: Version
    let nonce: Data
    let cipherText: Data

    init (version: Version, nonce: Data, cipherText: Data) {
        self.version    = version
        self.nonce      = nonce
        self.cipherText = cipherText
    }
}

extension Encrypted: Payload {
    public var asData: Data {
        switch version {
        case .v2: return nonce + cipherText
        }
    }

    public init? (version: Version, data: Data) {
        switch version {
        case .v2:
            let nonceLen = Int(Aead.nonceBytes)

            guard data.count > nonceLen else { return nil }

            self.init(
                version:    version,
                nonce:      data[..<nonceLen],
                cipherText: data[nonceLen...]
            )
        }
    }
}
