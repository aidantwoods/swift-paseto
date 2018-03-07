//
//  Blob.swift
//  Paseto
//
//  Created by Aidan Woods on 05/03/2018.
//

import Foundation

public struct Blob<P: Payload> {
    public let header: Header
    public let payload: P
    public let footer: Data

    init (header: Header, payload: P, footer: Data = Data()) {
        self.header  = header
        self.payload = payload
        self.footer  = footer
    }

    init? (serialised string: String) {
        let parts = Header.split(string)

        guard [3, 4].contains(parts.count) else { return nil }

        guard let header  = Header(version: parts[0], purpose: parts[1]),
              let payload = P(encoded: parts[2])
        else { return nil }

        let footer: Data

        if parts.count > 3 { footer = Data(base64UrlNoPad: parts[3]) ?? Data() }
        else { footer = Data() }

        self.init(header: header, payload: payload, footer: footer)
    }
}

extension Blob {
    var asString: String {
        let main = header.asString + payload.encode
        guard !footer.isEmpty else { return main }
        return main + "." + footer.base64UrlNoPad
    }

    var asData: Data { return Data(self.asString.utf8) }
}
