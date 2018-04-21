//
//  Local.Payload.swift
//  Paseto_V2
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation
import Paseto_Core

extension Version2.Local: Module {
    public static var version: Version { return .v2 }

    public struct Payload {
        let nonce: Data
        let cipherText: Data
    }
}

extension Version2.Local.Payload: Paseto_Core.Payload {
    public typealias Module = Version2.Local

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
