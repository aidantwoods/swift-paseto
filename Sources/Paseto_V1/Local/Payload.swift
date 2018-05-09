//
//  Payload.swift
//  Paseto_V1
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation
import Paseto_Core

extension Version1.Local: Module {
    public static var version: Version { return .v1 }

    public struct Payload {
        let nonce: Data
        let cipherText: Data
        let mac: Data
    }
}

extension Version1.Local.Payload: Paseto_Core.Payload {
    public typealias Module = Version1.Local

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
