//
//  Key.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

protocol Key {
    var material: Data { get }
    static var version: Version { get }

    init (material: Data) throws
}

extension Key {
    var encode: String { return material.base64UrlNoPad }

    public init (encoded: String) throws {
        guard let decoded = Data(base64UrlNoPad: encoded) else {
            throw KeyException.badEncoding("Could not base64 URL decode.")
        }
        try self.init(material: decoded)
    }
}

public enum KeyException: Error {
    case badEncoding(String)
}
