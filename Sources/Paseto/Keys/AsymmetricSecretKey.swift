//
//  AsymmetricSecretKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public struct AsymmetricSecretKey {
    public let version: Version
    public let material: Data

    let secretBytes : Int = Sign.SecretKeyBytes
    let seedBytes   : Int = Sign.SeedBytes
    let keypairBytes: Int = 96

    init (material: Data, version: Version = .v2) throws {
        switch version {
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

        self.version = version
    }

    init? (version: Version = .v2) {
        switch version {
        case .v2:
            guard let secretKey = Sign.keyPair()?.secretKey else { return nil }

            do { try self.init(material: secretKey, version: version) }
            catch { return nil }
        }
    }

    var publicKey: AsymmetricPublicKey {
        return try! AsymmetricPublicKey(
            material: Sign.keyPair(seed: material[..<seedBytes])!.publicKey
        )
    }
}

extension AsymmetricSecretKey: Key {
    public init (encoded: String, version: Version = .v2) throws {
        guard let decoded = Data(base64UrlNoPad: encoded) else {
            throw Exception.badEncoding("Could not base64 URL decode.")
        }
        try self.init(material: decoded, version: version)
    }
}

extension AsymmetricSecretKey {
    enum Exception: Error {
        case badLength(String)
        case badMaterial(String)
        case badEncoding(String)
    }
}
