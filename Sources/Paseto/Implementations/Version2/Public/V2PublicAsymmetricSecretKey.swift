//
//  V2PublicAsymmetricSecretKey.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

extension Version2.Public.AsymmetricSecretKey: Paseto.AsymmetricSecretKey {
    public typealias Implementation = Version2.Public

    public init (material: Data) throws {
        switch material.count {
        case secretBytes:
            self.material = material

        case keypairBytes:
            self.material = material[..<secretBytes]

        case seedBytes:
            guard let keyPair = Sign.keyPair(seed: material) else {
                throw Exception.badMaterial(
                    "The material given could not be used to construct a"
                        + " key."
                )
            }
            self.material = keyPair.secretKey

        default:
            throw Exception.badLength(
                "Secret key must be 64 or 32 bytes long;"
                    + "\(material.count) given."
            )
        }
    }

    public init () {
        let secretKey = Sign.keyPair()!.secretKey
        try! self.init(material: secretKey)
    }

    public var publicKey: Version2.Public.AsymmetricPublicKey {
        return try! Version2.Public.AsymmetricPublicKey(
            material: Sign.keyPair(seed: material[..<seedBytes])!.publicKey
        )
    }
}

extension Version2.Public.AsymmetricSecretKey {
    enum Exception: Error {
        case badLength(String)
        case badMaterial(String)
    }
}
