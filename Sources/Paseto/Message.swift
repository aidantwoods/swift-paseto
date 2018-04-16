//
//  Message.swift
//  Paseto
//
//  Created by Aidan Woods on 05/03/2018.
//

import Foundation

public struct Message<I: Implementation> {
    public typealias ImplementationType = I
    public typealias PayloadType = I.Payload

    public let header: Header = Message.header
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
        ) = Message.deconstruct(string)
        else { return nil }

        guard header == Message.header,
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
            version: Version(implementation: I.self),
            purpose: Purpose(payload: PayloadType.self)
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

extension Message {
    enum Exception: Error {
        case badEncoding(String)
    }
}

extension Message {
    func token(jsonData: Data) throws -> Token {
        guard let footer = self.footer.utf8String else {
            throw Message<I>.Exception.badEncoding(
                "Could not convert the footer to a UTF-8 string."
            )
        }

        return try Token(
            jsonData: jsonData,
            footer: footer,
            allowedVersions: [header.version]
        )
    }
}   

extension Message where I: BasePublic {
    public func verify(with key: I.AsymmetricPublicKey) throws -> Token {
        let message = try I.verify(self, with: key)
        return try token(jsonData: message)
    }

    public func verify(with key: I.AsymmetricPublicKey) -> Token? {
        return try? verify(with: key)
    }
}

extension Message where I: BaseLocal {
    public func decrypt(with key: I.SymmetricKey) throws -> Token {
        let message = try I.decrypt(self, with: key)
        return try token(jsonData: message)
    }

    public func decrypt(with key: I.SymmetricKey) -> Token? {
        return try? decrypt(with: key)
    }
}
