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
    init? (base64: String) {
        guard let data = Data(base64UrlNoPad: base64) else { return nil }
        self.init(data: data)
    }

    var base64: String { return self.asData.base64UrlNoPad }
}
