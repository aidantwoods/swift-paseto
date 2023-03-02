import Foundation
import CryptoKit
import CryptoSwift

fileprivate let zeroBn = BigUInteger(0)
fileprivate let oneBn = BigUInteger(1)
fileprivate let twoBn = BigUInteger(2)
fileprivate let fourBn = BigUInteger(4)

// The following consts are extracted from the NIST spec.
// https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-186-draft.pdf

// p = 2^384 − 2^128 − 2^96 + 2^32 − 1
fileprivate let pBn = twoBn.power(384) - twoBn.power(128) - twoBn.power(96) + twoBn.power(32) - 1

// a = -3 mod p
//   = 3940200619639447921227904010014361380507973927046544666794\
//     8293404245721771496870329047266088258938001861606973112316
fileprivate let aBn = BigUInteger("39402006196394479212279040100143613805079739270465446667948293404245721771496870329047266088258938001861606973112316", radix: 10)!

// b = 2758019355995970587784901184038904809305690585636156852142\
//     8707301988689241309860865136260764883745107765439761230575
fileprivate let bBn = BigUInteger("27580193559959705877849011840389048093056905856361568521428707301988689241309860865136260764883745107765439761230575", radix: 10)!

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, macCatalyst 14, *)
extension Version3.Public {
    public struct AsymmetricPublicKey  {
        public static let length = 49

        let key: P384.Signing.PublicKey

        // https://www.secg.org/sec1-v2.pdf
        fileprivate static func decompressToCoords(compressedKey: Bytes) throws -> (x: Bytes, y: Bytes) {
            guard compressedKey.count == 1 + 48 else {
                throw Exception.badKey("Bad public key length")
            }

            if compressedKey == Bytes(repeating: 0, count: 49) {
                return (x: Bytes(repeating: 0, count: 48), y: Bytes(repeating: 0, count: 48))
            }

            let prefix = compressedKey[0]
            let x = compressedKey[1...].bytes

            let yTildeP: BigUInteger
            switch prefix {
            case 02:
                yTildeP = zeroBn
            case 03:
                yTildeP = oneBn
            default:
                throw Exception.badKey("Bad public key prefix")
            }

            let xBn = BigUInteger(Data(x))

            let alpha = (xBn.power(3) + (aBn * xBn) + bBn) % pBn

            // Take square root mod p
            // https://en.wikipedia.org/wiki/Tonelli%E2%80%93Shanks_algorithm
            // For prime p = 3 (mod 4), r = n ^ ((p+1)/n) (mod p) is a root of r^2 = n (mod p), if a square root exists
            let beta = alpha.power((pBn + 1)/4, modulus: pBn)

            // check square root exists
            guard beta.power(2, modulus: pBn) == alpha else {
                throw Exception.badKey("Square root not found")
            }

            let yBn: BigUInteger
            if beta % 2 == yTildeP {
                yBn = beta
            } else {
                yBn = pBn - beta
            }

            let y = Bytes(yBn.serialize())

            guard y.count <= 48 else {
                throw Exception.badKey("Invalid y byte length")
            }

            let yPadded = Bytes(repeating: 0, count: 48 - y.count) + y

            return (x, yPadded)
        }

        fileprivate static func decompress(compressedKey: Bytes) throws -> P384.Signing.PublicKey {
            let (x, y) = try decompressToCoords(compressedKey: compressedKey)
            return try P384.Signing.PublicKey(rawRepresentation: x + y)
        }

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

            self.key = try Self.decompress(compressedKey: material)
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
