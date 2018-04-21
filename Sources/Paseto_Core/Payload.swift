//
//  Payload.swift
//  Paseto_Core
//
//  Created by Aidan Woods on 07/03/2018.
//

import Foundation

public protocol Payload {
    associatedtype Module: Paseto_Core.Module
    static var purpose: Purpose { get }
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

public extension Payload where Self.Module: Local {
    static var purpose: Purpose { return .Local }
}

public extension Payload where Self.Module: Public {
    static var purpose: Purpose { return .Public }
}
