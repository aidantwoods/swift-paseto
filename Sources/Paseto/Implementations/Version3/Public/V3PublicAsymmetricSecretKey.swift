import Foundation
import CryptoKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, macCatalyst 13, *)
extension Version3.Public {
    public struct AsymmetricSecretKey {
        public static let length = 48

        let key: P384.Signing.PrivateKey

        public var material: Bytes {
            key.rawRepresentation.bytes
        }


        public init (material: Bytes) throws {
            let length = Module.AsymmetricSecretKey.length

            guard material.count == length else {
                throw Exception.badLength(
                    "Secret key must be \(length) bytes long;"
                        + "\(material.count) given."
                )
            }

            guard let key = try? P384.Signing.PrivateKey(rawRepresentation: material) else {
                throw Exception.badMaterial("Secret key was invalid")
            }

            self.init(key: key)
        }

        init (key: P384.Signing.PrivateKey) {
            self.key = key
        }
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, macCatalyst 13, *)
extension Version3.Public.AsymmetricSecretKey: Paseto.AsymmetricSecretKey {
    public typealias Module = Version3.Public

    public init () {
        let secretKey = P384.Signing.PrivateKey(compactRepresentable: true)
        self.init(key: secretKey)
    }

    public var publicKey: Version3.Public.AsymmetricPublicKey {
        return Version3.Public.AsymmetricPublicKey (
            key: key.publicKey
        )
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, macCatalyst 13, *)
extension Version3.Public.AsymmetricSecretKey {
    enum Exception: Error {
        case badLength(String)
        case badMaterial(String)
    }
}
