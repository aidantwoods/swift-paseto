//
//  V2PublicAsymmetricPublicKey.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

extension Version2.Public {
    public struct AsymmetricPublicKey  {
        public static let length = Sign.PublicKeyBytes

        public let material: Bytes

        public init (material: Bytes) throws {
            guard material.count == Module.AsymmetricPublicKey.length else {
                throw Exception.badLength(
                    "Public key must be 32 bytes long; \(material.count) given."
                )
            }

            self.material = material
        }
    }
}

extension Version2.Public.AsymmetricPublicKey : Paseto.AsymmetricPublicKey {
    public typealias Module = Version2.Public
}

public extension Version2.Public.AsymmetricPublicKey  {
    enum Exception: Error {
        case badLength(String)
    }
}
