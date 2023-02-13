import Foundation
import CryptoKit

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, macCatalyst 14, *)
extension Version3.Public {
    public struct AsymmetricPublicKey  {
        public static let length = 49

        let key: P384.Signing.PublicKey

        fileprivate static func compress(key: P384.Signing.PublicKey) -> Bytes {
            let x963Representation = key.x963Representation.bytes

            guard x963Representation[0] == 04 else {
                guard x963Representation[0] == 03 || x963Representation[0] == 02 else {
                    fatalError("Unhandlable output from .x963Representation")
                }

                // 02 or 03 is a compressed point

                guard x963Representation.count == 1 + 48 else {
                    fatalError("Unhandlable output from .x963Representation")
                }

                return x963Representation
            }

            // 04 indicates uncompressed, we can parse this and compress

            guard x963Representation.count == 1 + 48 + 48 else {
                fatalError("Unhandlable output from .x963Representation")
            }

            let xyBytes = x963Representation[1...].bytes

            let xBytes = xyBytes[0..<48].bytes
            let yBytes = xyBytes[48...].bytes

            let yTildeP = yBytes[47] % 2

            let prefix: UInt8

            if yTildeP == 0 {
                prefix = 02
            } else {
                prefix = 03
            }

            return [prefix] + xBytes
        }

        var compressed: Bytes {
            Self.compress(key: key)
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

            if #available(macOS 13, iOS 16, watchOS 9, tvOS 16, macCatalyst 16, *) {
                guard
                    let key = try? P384.Signing.PublicKey(compressedRepresentation: material) else {
                    throw Exception.badKey("Public key is invalid")
                }
                self.key = key
            } else {
                // Note that this would actually fail on newer versions, so it seems there was a BC break
                // here which means this constructor will no longer accept compressed points like it once
                // did.
                guard
                    let key = try? P384.Signing.PublicKey(x963Representation: material) else {
                    throw Exception.badKey("Public key is invalid")
                }
                self.key = key
            }
        }

        init (_ key: P384.Signing.PublicKey) {
            self.key = key
        }

        // Imports a P384.Signing.PublicKey. This method will throw if the public key
        // contains an invalid curve point.
        public init (key: P384.Signing.PublicKey) throws {
            // Rather than explicitly checking the co-ordinates here, the stratergy is
            // to export the public key raw and compressed, then use the safe compressed
            // constructor. If we detect a change between the imported key and the
            // original key then we error.

            // store starting bytes
            let givenRawBytes = key.rawRepresentation.bytes

            // compress and parse as compressed
            try self.init(material: Self.compress(key: key))

            let parsedRawBytes = self.key.rawRepresentation.bytes

            // assert that parsed compressed bytes match input bytes
            guard Util.equals(givenRawBytes, parsedRawBytes) else {
                throw Exception.badKey("Public key is invalid")
            }
        }
    }
}

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, macCatalyst 14, *)
extension Version3.Public.AsymmetricPublicKey : Paseto.AsymmetricPublicKey {
    public typealias Module = Version3.Public
}

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, macCatalyst 14, *)
public extension Version3.Public.AsymmetricPublicKey  {
    enum Exception: Error {
        case badLength(String)
        case badKey(String)
    }
}
