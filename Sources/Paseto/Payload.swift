//
//  Payload.swift
//  Paseto
//
//  Created by Aidan Woods on 07/03/2018.
//

import Foundation

public protocol Payload: BytesRepresentable {}

extension Payload {
    init? (encoded: String) {
        guard let data = Data(base64UrlNoPad: encoded) else { return nil }
        self.init(bytes: data)
    }

    var encode: String { return self.base64UrlNoPad }
}
