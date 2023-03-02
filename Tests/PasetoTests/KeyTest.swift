import XCTest
@testable import Paseto
import CryptoKit
import Sodium

class KeyTest: XCTestCase {
    func testInvalidKeyImport() {
        if #available(macOS 11, iOS 14, watchOS 7, tvOS 14, macCatalyst 14, *) {
            let material = sodium.utils.hex2bin( "04fbcb7c69ee1c60579be7a334134878d9c5c5bf35d552dab63c0140397ed14cef637d7720925c44699ea30e72874c72fbfbcb7c69ee1c60579be7a334134878d9c5c5bf35d552dab63c0140397ed14cef637d7720925c44699ea30e72874c72fb")!

            // import invalid key
            let pubKey = try! P384.Signing.PublicKey(x963Representation: material)

            // should detect invalid key
            XCTAssertThrowsError(try Paseto.Version3.AsymmetricPublicKey(key: pubKey))
        } else {
            _ = XCTSkip("Skipping key test where key is not supported")
        }
    }

    func testGeneratedKeyImport() {
        if #available(macOS 13, *) {
            for _ in 1...100 {
                let privKey = P384.Signing.PrivateKey(compactRepresentable: false)

                let pubKey = privKey.publicKey

                let pasetoPubKey = Paseto.Version3.AsymmetricPublicKey(bytes: pubKey.compressedRepresentation)!

                XCTAssertEqual(pubKey.rawRepresentation.bytes, pasetoPubKey.key.rawRepresentation.bytes)
            }
        } else {
            _ = XCTSkip("Skipping key test where key is not supported")
        }
    }

    func testRandomKeyImport() {
        if #available(macOS 13, *) {
            for _ in 1...100 {
                let bytes = [Util.random(length: 1)[0] % 2 == 0 ? 02 : 03] + Util.random(length: 48)

                let pasetoPubKey = Paseto.Version3.AsymmetricPublicKey(bytes: bytes)
                let pubKey = try? P384.Signing.PublicKey(compressedRepresentation: bytes)

                XCTAssertEqual(pubKey?.rawRepresentation.bytes, pasetoPubKey?.key.rawRepresentation.bytes)
            }
        } else {
            _ = XCTSkip("Skipping key test where key is not supported")
        }
    }
}

