//
//  Blob.swift
//  Paseto
//
//  Created by Aidan Woods on 05/03/2018.
//

import Foundation

public struct Blob<P: Payload>: MetaBlob {
    public typealias VersionType = P.VersionType
    public typealias PayloadType = P

    public let header: Header = Blob.header
    let payload: PayloadType
    public let footer: Data

    init (payload: PayloadType, footer: Data = Data()) {
        self.payload = payload
        self.footer  = footer
    }

    public init? (_ string: String) {
        guard let (
            header: header,
            encodedPayload: encodedPayload,
            encodedFooter: encodedFooter
        ) = Blob.deconstruct(string)
        else { return nil }

        guard header == Blob.header,
              let payload = PayloadType(encoded: encodedPayload),
              let footer = Data(base64UrlNoPad: encodedFooter)
        else { return nil }

        self.init(payload: payload, footer: footer)
    }

    internal static func deconstruct(
        _ string: String
    ) -> (header: Header, encodedPayload: String, encodedFooter: String)? {
        let parts = string.split(with: ".")

        guard [3, 4].contains(parts.count) else { return nil }

        guard let header = Header(version: parts[0], purpose: parts[1])
        else { return nil }

        return (
            header: header,
            encodedPayload: parts[2],
            encodedFooter: parts.count > 3 ? parts[3] : ""
        )
    }

    public static var header: Header {
        return Header(
            version: Version(implementation: VersionType.self),
            purpose: Purpose(payload: PayloadType.self)
        )
    }
}

public extension Blob {
    public var asString: String {
        let main = header.asString + payload.encode
        guard !footer.isEmpty else { return main }
        return main + "." + footer.base64UrlNoPad
    }

    public var asData: Data { return Data(self.asString.utf8) }
}

extension Blob {
    enum Exception: Error {
        case badEncoding(String)
    }
}
