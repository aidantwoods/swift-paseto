import Foundation
import CryptoKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, macCatalyst 13, *)
extension Version3.Public {
    public struct AsymmetricPublicKey  {
        public static let length = 49

        let key: P384.Signing.PublicKey

        var compressed: Bytes {
            [02] + key.compactRepresentation!.bytes
        }

        public var material: Bytes {
            compressed
        }

        public init (material: Bytes) throws {
            guard material.count == Module.AsymmetricPublicKey.length else {
                throw Exception.badLength(
                    "Public key must be 49 bytes long; \(material.count) given."
                )
            }

            guard let key = try? P384.Signing.PublicKey(x963Representation: material) else {
                throw Exception.badKey("Public key is invalid")
            }

            self.key = key
        }

        init (key: P384.Signing.PublicKey) {
            self.key = key
        }
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, macCatalyst 13, *)
extension Version3.Public.AsymmetricPublicKey : Paseto.AsymmetricPublicKey {
    public typealias Module = Version3.Public
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, macCatalyst 13, *)
public extension Version3.Public.AsymmetricPublicKey  {
    enum Exception: Error {
        case badLength(String)
        case badKey(String)
    }
}
