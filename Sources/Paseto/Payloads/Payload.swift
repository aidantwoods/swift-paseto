//
//  Payload.swift
//  Paseto
//
//  Created by Aidan Woods on 07/03/2018.
//

import Foundation

public protocol Payload {
    init? (version: Version, data: Data)
    var asData: Data { get }
}

extension Payload {
    init? (version: Version, encoded: String) {
        guard let data = Data(base64UrlNoPad: encoded) else { return nil }
        self.init(version: version, data: data)
    }

    var encode: String { return self.asData.base64UrlNoPad }
}
