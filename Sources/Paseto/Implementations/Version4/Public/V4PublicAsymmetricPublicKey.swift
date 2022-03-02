import Foundation

extension Version4.Public {
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

extension Version4.Public.AsymmetricPublicKey : Paseto.AsymmetricPublicKey {
    public typealias Module = Version4.Public
}

public extension Version4.Public.AsymmetricPublicKey  {
    enum Exception: Error {
        case badLength(String)
    }
}
