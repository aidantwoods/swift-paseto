//
//  SymmetricKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Sodium
import Foundation

public struct SymmetricKey: Key {
    public let version: Version
    public let material: Data
    
    var encode: String { return material.base64UrlNpEncoded }
    
    init (material: Data, version: Version = .v2) {
        self.material = material
        self.version = version
    }
    
    init (version: Version = .v2) {
        self.init(material: Sodium().secretBox.key()!, version: version)
    }
    
    init (base64: String, version: Version = .v2) throws {
        guard let decoded = Data(base64UrlNpEncoded: base64) else {
            throw Exception.badEncoding("Could not base64 URL decode.")
        }
        self.init(material: decoded, version: version)
    }
    
    enum Exception: Error {
        case badEncoding(String)
    }
}
