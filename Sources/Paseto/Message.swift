//
//  Message.swift
//  Paseto
//
//  Created by Aidan Woods on 05/03/2018.
//

import Foundation

public struct Message<M: Module> {
    public typealias Module = M
    public typealias Payload = M.Payload

    public let header: Header = Message.header
    let payload: Payload
    public let footer: Bytes

    init (payload: Payload, footer: BytesRepresentable = Bytes()) {
        self.payload = payload
        self.footer  = footer.bytes
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
              let footer = Bytes(fromBase64: encodedFooter)
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
            version: Version(module: M.self),
            purpose: Purpose(payload: Payload.self)
        )
    }
}

public extension Message {
    var asString: String {
        let main = header.asString + payload.encode
        guard !footer.isEmpty else { return main }
        return main + "." + footer.toBase64
    }

    var asData: Data { return Data(bytes: self.asString) }
}

extension Message {
    enum Exception: Error {
        case badEncoding(String)
    }
}

extension Message {
    func token(package: Package) throws -> Token {
        guard let footer = String(bytes: package.footer) else {
            throw Exception.badEncoding(
                "Could not convert the footer to a UTF-8 string."
            )
        }

        return try Token(
            jsonData: Data(bytes: package.content),
            footer: footer,
            allowedVersions: [header.version]
        )
    }
}   

extension Message where M: BasePublic {
    public func verify(with key: M.AsymmetricPublicKey) throws -> Token {
        let package = try M.verify(self, with: key)
        return try token(package: package)
    }
}

extension Message where M: BaseLocal {
    public func decrypt(with key: M.SymmetricKey) throws -> Token {
        let package = try M.decrypt(self, with: key)
        return try token(package: package)
    }
}
