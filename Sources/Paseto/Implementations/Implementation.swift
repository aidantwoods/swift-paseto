//
//  Version.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public protocol Implementation {
    static var version: Version { get }
//    static func encrypt(
//        _ data: Data, with key: SymmetricKey, footer: Data
//    ) -> Blob
//
//    static func decrypt(
//        _ data: Blob, with key: SymmetricKey, footer: Data
//    ) -> Data
    
    static func sign(
        _ data: Data, with key: AsymmetricSecretKey, footer: Data
    ) -> Blob
    
    static func verify(
        _ signedMessage: Blob, with key: AsymmetricPublicKey, footer: Data
    ) throws -> Data
}

extension Implementation {
//    static func encrypt(_ data: Data, with key: SymmetricKey) -> Blob {
//        return encrypt(data, with: key, footer: Data("".utf8))
//    }
//
//    static func decrypt(_ data: Blob, with key: SymmetricKey) -> Data {
//        return decrypt(data, with: key, footer: Data("".utf8))
//    }
    
    static func sign(_ data: Data, with key: AsymmetricSecretKey) -> Blob {
        return sign(data, with: key, footer: Data())
    }
    
    static func verify(
        _ signedMessage: Blob, with key: AsymmetricPublicKey
    ) throws -> Data {
        return try verify(signedMessage, with: key, footer: Data())
    }
}

