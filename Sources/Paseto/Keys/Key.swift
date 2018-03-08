//
//  Key.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public protocol Key {
    var material: Data { get }
    static var version: Version { get }

    init (encoded: String) throws
}

extension Key {
    var encode: String { return material.base64UrlNoPad }
}
