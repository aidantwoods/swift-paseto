//
//  V2PublicAsymmetricPublicKey.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

extension Version2.Public {
    public struct AsymmetricPublicKey  {
        public let material: Data

        public init (material: Data) throws {
            guard material.count == Sign.PublicKeyBytes else {
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
