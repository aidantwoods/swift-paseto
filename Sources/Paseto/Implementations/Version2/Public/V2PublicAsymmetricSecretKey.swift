//
//  V2PublicAsymmetricSecretKey.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

extension Version2.Public {
    public struct AsymmetricSecretKey {
        public let material: Bytes

        let secretBytes  = Sign.SecretKeyBytes
        let seedBytes    = Sign.SeedBytes
        let keypairBytes = 96

        public init (material: Bytes) throws {
            switch material.count {
            case secretBytes:
                self.material = material

            case keypairBytes:
                self.material = material[..<secretBytes].bytes

            case seedBytes:
                guard let keyPair = Sign.keyPair(seed: Data(bytes: material)) else {
                    throw Exception.badMaterial(
                        "The material given could not be used to construct a"
                            + " key."
                    )
                }
                self.material = keyPair.secretKey.bytes

            default:
                throw Exception.badLength(
                    "Secret key must be 64 or 32 bytes long;"
                        + "\(material.count) given."
                )
            }
        }
    }
}

extension Version2.Public.AsymmetricSecretKey: Paseto.AsymmetricSecretKey {
    public typealias Module = Version2.Public

    public init () {
        let secretKey = Sign.keyPair()!.secretKey.bytes
        try! self.init(material: secretKey)
    }

    public var publicKey: Version2.Public.AsymmetricPublicKey  {
        return Version2.Public.AsymmetricPublicKey (
            bytes: Sign.keyPair(seed: Data(bytes: material[..<seedBytes]))!.publicKey
        )!
    }
}

extension Version2.Public.AsymmetricSecretKey {
    enum Exception: Error {
        case badLength(String)
        case badMaterial(String)
    }
}
