//
//  Header.swift
//  Paseto
//
//  Created by Aidan Woods on 06/03/2018.
//

import Foundation

public struct Header {
    public let version: Version
    public let purpose: Purpose

    init (version: Version, purpose: Purpose) {
        self.version = version
        self.purpose = purpose
    }

    init? (version v: String, purpose p: String) {
        guard let version = Version(rawValue: v),
              let purpose = Purpose(rawValue: p)
        else { return nil }

        self.init(version: version, purpose: purpose)
    }

    init? (serialised: String) {
        let parts = serialised.split(with: ".")

        guard parts.count == 3, parts[2] == "" else { return nil }

        self.init(version: parts[0], purpose: parts[1])
    }
}

extension Header {
    var asString: String {
        return [version.rawValue, purpose.rawValue].joined(separator: ".") + "."
    }
}

extension Header: BytesRepresentable {
    public var bytes: Bytes { return self.asString.bytes }

    public init? (bytes: Bytes) {
        guard let header = String(bytes: bytes).flatMap(Header.init(serialised:))
        else { return nil }

        self = header
    }
}

extension Header: Equatable {
    public static func == (left: Header, right: Header) -> Bool {
        return left.version == right.version && left.purpose == right.purpose
    }
}
