//
//  EncryptedPayload.swift
//  Paseto
//
//  Created by Aidan Woods on 08/03/2018.
//

import Foundation

public struct Encrypted<V: Implementation> {
    let nonce: Data
    let cipherText: Data
    let mac: Data

    init (nonce: Data, cipherText: Data, mac: Data = Data()) {
        self.nonce      = nonce
        self.cipherText = cipherText
        self.mac        = mac
    }
}

extension Encrypted: VersionedPayload {
    public typealias VersionType = V
    public var asData: Data {
        switch Encrypted.version {
        case .v1: return nonce + cipherText + mac
        case .v2: return nonce + cipherText
        }
    }

    public init? (data: Data) {
        switch Encrypted.version {
        case .v1:
            let nonceLen = Version1.nonceBytes
            let macLen   = Version1.macBytes

            guard data.count > nonceLen + macLen else { return nil }

            let macOffset = data.count - macLen

            self.init(
                nonce:      data[..<nonceLen],
                cipherText: data[nonceLen..<macOffset],
                mac:        data[macOffset...]
            )

        case .v2:
            let nonceLen = Int(Aead.nonceBytes)

            guard data.count > nonceLen else { return nil }

            self.init(
                nonce:      data[..<nonceLen],
                cipherText: data[nonceLen...]
            )
        }
    }
}
