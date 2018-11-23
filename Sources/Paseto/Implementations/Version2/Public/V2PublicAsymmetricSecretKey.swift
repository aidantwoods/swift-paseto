//
//  V2PublicAsymmetricSecretKey.swift
//  Paseto
//
//  Created by Aidan Woods on 16/04/2018.
//

import Foundation

extension Version2.Public {
    public struct AsymmetricSecretKey {
        public static let length        = Sign.SecretKeyBytes
        public static let seedLength    = Sign.SeedBytes
        public static let keypairLength = 96

        public let material: Bytes

        public init (material: Bytes) throws {
            let length = Module.AsymmetricSecretKey.length

            guard material.count == length else {
                throw Exception.badLength(
                    "Secret key must be \(length) bytes long;"
                        + "\(material.count) given."
                )
            }

            self.material = material
        }
    }
}

extension Version2.Public.AsymmetricSecretKey {
    public init (keypair material: Bytes) throws {
        let keypairLength = Module.AsymmetricSecretKey.keypairLength

        guard material.count == keypairLength else {
            throw Exception.badLength(
                "Keypair must be \(keypairLength) bytes long;"
                    + "\(material.count) given."
            )
        }

        self.material = material[..<Module.AsymmetricSecretKey.length].bytes
    }

    public init (seed material: Bytes) throws {
        let seedLength = Module.AsymmetricSecretKey.seedLength

        guard material.count == seedLength else {
            throw Exception.badLength(
                "Seed must be \(seedLength) bytes long;"
                    + "\(material.count) given."
            )
        }

        guard let keyPair = Sign.keyPair(seed: material) else {
            throw Exception.badMaterial(
                "The seed material given could not be used to construct a"
                    + " keypair."
            )
        }

        self.material = keyPair.secretKey
    }
}

extension Version2.Public.AsymmetricSecretKey: Paseto.AsymmetricSecretKey {
    public typealias Module = Version2.Public

    public init () {
        let secretKey = Sign.keyPair()!.secretKey
        try! self.init(material: secretKey)
    }

    var seed: Bytes {
        return material[..<Module.AsymmetricSecretKey.seedLength].bytes
    }

    public var publicKey: Version2.Public.AsymmetricPublicKey {
        return Version2.Public.AsymmetricPublicKey (
            bytes: Sign.keyPair(seed: self.seed)!.publicKey
        )!
    }
}

extension Version2.Public.AsymmetricSecretKey {
    enum Exception: Error {
        case badLength(String)
        case badMaterial(String)
    }
}
