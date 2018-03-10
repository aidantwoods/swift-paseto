//
//  Payload.swift
//  Paseto
//
//  Created by Aidan Woods on 07/03/2018.
//

import Foundation

public protocol Payload {
    init? (data: Data)
    var asData: Data { get }
}

extension Payload {
    init? (encoded: String) {
        guard let data = Data(base64UrlNoPad: encoded) else { return nil }
        self.init(data: data)
    }

    var encode: String { return self.asData.base64UrlNoPad }
}
