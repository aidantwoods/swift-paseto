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

    var asString: String {
        return [version.rawValue, purpose.rawValue].joined(separator: ".") + "."
    }

    var asData: Data { return Data(self.asString.utf8) }

    init (version: Version, purpose: Purpose) {
        self.version = version
        self.purpose = purpose
    }

    init? (version v: String, purpose p: String) {
        guard let version = Version(rawValue: v),
              let purpose = Purpose(rawValue: p)
        else {
                return nil
        }

        self.init(version: version, purpose: purpose)
    }

    init? (serialised string: String) {
        let parts = Blob.split(string)

        guard parts.count == 3 else { return nil }

        guard let header = Header(version: parts[0], purpose: parts[1]),
              parts[2] == ""
        else { return nil }

        self = header
    }
}

extension Header: Equatable {
    public static func == (left: Header, right: Header) -> Bool {
        return left.version == right.version && left.purpose == right.purpose
    }
}
