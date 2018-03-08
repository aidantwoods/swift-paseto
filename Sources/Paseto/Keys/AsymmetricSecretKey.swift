//
//  AsymmetricSecretKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public struct AsymmetricSecretKey<V: Implementation> {
    public let material: Data

    let secretBytes : Int = Sign.SecretKeyBytes
    let seedBytes   : Int = Sign.SeedBytes
    let keypairBytes: Int = 96

    init (material: Data) throws {
        switch AsymmetricSecretKey.version {
        case .v2:
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
                    "Public key must be 64 or 32 bytes long;"
                    + "\(material.count) given."
                )
            }
        }
    }

    init () {
        switch AsymmetricSecretKey.version {
        case .v2:
            let secretKey = Sign.keyPair()!.secretKey
            try! self.init(material: secretKey)
        }
    }

    var publicKey: AsymmetricPublicKey<V> {
        return try! AsymmetricPublicKey(
            material: Sign.keyPair(seed: material[..<seedBytes])!.publicKey
        )
    }

    public static var version: Version {
        return Version(implementation: V.self)
    }
}

extension AsymmetricSecretKey: Key {
    public init (encoded: String) throws {
        guard let decoded = Data(base64UrlNoPad: encoded) else {
            throw Exception.badEncoding("Could not base64 URL decode.")
        }
        try self.init(material: decoded)
    }
}

extension AsymmetricSecretKey {
    enum Exception: Error {
        case badLength(String)
        case badMaterial(String)
        case badEncoding(String)
    }
}
