//
//  Public.Payload.swift
//  Paseto_V2
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation
import Paseto_Core

extension Version2.Public: Module {
    public static var version: Version { return .v2 }

    public struct Payload {
        let message: Data
        let signature: Data
    }
}

extension Version2.Public.Payload: Paseto_Core.Payload {
    public typealias Module = Version2.Public

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
