//
//  Message.swift
//  Paseto_Core
//
//  Created by Aidan Woods on 05/03/2018.
//

import Foundation

public struct Message<M: Module> {
    public typealias Module = M
    public typealias Payload = M.Payload

    public let header: Header = Message.header
    let payload: Payload
    public let footer: Data

    init (payload: Payload, footer: Data = Data()) {
        self.payload = payload
        self.footer  = footer
    }

    public init? (_ string: String) {
        guard let (
            header: header,
            encodedPayload: encodedPayload,
            encodedFooter: encodedFooter
        ) = Message.deconstruct(string)
        else { return nil }

        guard header == Message.header,
              let payload = Payload(encoded: encodedPayload),
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
            version: M.version,
            purpose: Payload.purpose
        )
    }
}

public extension Message {
    public var asString: String {
        let main = header.asString + payload.encode
        guard !footer.isEmpty else { return main }
        return main + "." + footer.base64UrlNoPad
    }

    public var asData: Data { return Data(self.asString.utf8) }
}

public extension Message {
    public enum Exception: Error {
        case badEncoding(String)
    }
}
