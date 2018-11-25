//
//  Key.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public protocol Key: BytesRepresentable {
    associatedtype Module: Paseto.Module
    var material: Bytes { get }
    init (material: Bytes) throws
}

public extension Key {
    var bytes: Bytes { return self.material }

    init? (bytes: Bytes) {
        try? self.init(material: bytes)
    }
}

extension Key {
    public var encode: String { return material.toBase64 }

    public init (encoded: String) throws {
        guard let decoded = Bytes(fromBase64: encoded) else {
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
}

public enum KeyException: Error {
    case badEncoding(String)
}
