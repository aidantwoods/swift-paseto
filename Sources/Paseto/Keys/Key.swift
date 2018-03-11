//
//  Key.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

protocol Key {
    associatedtype VersionType: Implementation

    var material: Data { get }
    init (material: Data) throws
}

extension Key {
    public var encode: String { return material.base64UrlNoPad }

    public init (encoded: String) throws {
        guard let decoded = Data(base64UrlNoPad: encoded) else {
            throw KeyException.badEncoding("Could not base64 URL decode.")
        }
        try self.init(material: decoded)
    }

    public init (hex: String) throws {
        guard let decoded = sodium.utils.hex2bin(hex) else {
            throw KeyException.badEncoding("Could not hex decode.")
        }
        try self.init(material: decoded)
    }

    public static var version: Version { return VersionType.version }
}

public enum KeyException: Error {
    case badEncoding(String)
}
