//
//  SignedPayload.swift
//  Paseto
//
//  Created by Aidan Woods on 07/03/2018.
//

import Foundation

public struct Signed<V: Implementation> {
    let message: Data
    let signature: Data

    init (message: Data, signature: Data) {
        self.message   = message
        self.signature = signature
    }
}

extension Signed: Payload {
    public typealias VersionType = V
    public var asData: Data {
        switch Signed.version {
        case .v1:
            fatalError("""
                Not implemented.
                Swift's standard library requires at least OSX 10.13 to use the
                RSA that we need. There isn't much value in only implementing
                this for one platform. Alternative solution is sought.
                """
            )

        case .v2: return message + signature
        }
    }

    public init? (data: Data) {
        switch Signed.version {
        case .v1:
            fatalError("""
                Not implemented.
                Swift's standard library requires at least OSX 10.13 to use the
                RSA that we need. There isn't much value in only implementing
                this for one platform. Alternative solution is sought.
                """
            )

        case .v2:
            let signatureOffset = data.count - Sign.Bytes

            guard signatureOffset > 0 else { return nil }

            self.init(
                message:   data[..<signatureOffset],
                signature: data[signatureOffset...]
            )
        }
    }
}
