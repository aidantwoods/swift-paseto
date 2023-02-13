import XCTest
@testable import Paseto
import CryptoKit
import Sodium

class KeyTest: XCTestCase {
    func testInvalidKeyImport() {
        let material = sodium.utils.hex2bin( "04fbcb7c69ee1c60579be7a334134878d9c5c5bf35d552dab63c0140397ed14cef637d7720925c44699ea30e72874c72fbfbcb7c69ee1c60579be7a334134878d9c5c5bf35d552dab63c0140397ed14cef637d7720925c44699ea30e72874c72fb")!
        
        // import invalid key
        let pubKey = try! P384.Signing.PublicKey(x963Representation: material)
        
        // should detect invalid key
        XCTAssertThrowsError(try Paseto.Version3.AsymmetricPublicKey(key: pubKey))
    }
}

