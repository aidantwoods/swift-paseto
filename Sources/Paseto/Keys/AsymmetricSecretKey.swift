//
//  AsymmetricSecretKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public struct AsymmetricSecretKey<V: Implementation>: Key {
    typealias VersionType = V
    public let material: Data

    let secretBytes  = Sign.SecretKeyBytes
    let seedBytes    = Sign.SeedBytes
    let keypairBytes = 96

    public init () {
        switch AsymmetricSecretKey.version {
        case .v1:
            fatalError("""
                Not implemented.
                Swift's standard library requires at least OSX 10.13 to use the
                RSA that we need. There isn't much value in only implementing
                this for one platform. Alternative solution is sought.
                """
            )

        case .v2:
            let secretKey = Sign.keyPair()!.secretKey
            try! self.init(material: secretKey)
        }
    }

    public var publicKey: AsymmetricPublicKey<V> {
        switch AsymmetricSecretKey.version {
        case .v1:
            fatalError("""
                Not implemented.
                Swift's standard library requires at least OSX 10.13 to use the
                RSA that we need. There isn't much value in only implementing
                this for one platform. Alternative solution is sought.
                """
            )

        case .v2:
            return try! AsymmetricPublicKey(
                material: Sign.keyPair(seed: material[..<seedBytes])!.publicKey
            )
        }
    }
}

public extension AsymmetricSecretKey {
    init (material: Data) throws {
        switch AsymmetricSecretKey.version {
        case .v1:
            fatalError("""
                Not implemented.
                Swift's standard library requires at least OSX 10.13 to use the
                RSA that we need. There isn't much value in only implementing
                this for one platform. Alternative solution is sought.
                """
            )

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
}

public extension AsymmetricSecretKey {
    enum Exception: Error {
        case badLength(String)
        case badMaterial(String)
    }
}
