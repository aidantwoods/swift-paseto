import XCTest
import Paseto
import Sodium

class Version3Test: XCTestCase {
    func testEncrypt() {
        let sk = Version3.SymmetricKey()

        let message = """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec
            pretium orci enim, tincidunt bibendum diam suscipit et.
            Pellentesque vel sagittis sem, vitae tempor elit. Sed non suscipit
            augue. In hac habitasse platea dictumst. Nunc consectetur et urna
            ac molestie. Nunc eleifend nisi nisl, non ornare nunc auctor sit
            amet. Sed eu sodales nibh. Etiam eros mi, molestie in nibh in,
            cursus ullamcorper augue. Duis id vestibulum nulla. Nulla in
            fermentum arcu. Nunc et nibh nec lacus pellentesque vulputate
            commodo vel sapien. Sed molestie, dui ac condimentum feugiat, magna
            risus tincidunt est, feugiat faucibus est magna at arcu. 👻
            """

        let encrypted = try! Version3.encrypt(message, with: sk)

        let decrypted = try! Version3.decrypt(encrypted, with: sk).string

        XCTAssertEqual(message, decrypted)
    }

    func testLargeishData() {
        let sk = Version3.SymmetricKey()

        let message = Sodium().randomBytes.buf(length: Int(1 << 17))!

        let blob = try! Version3.encrypt(message, with: sk)

        let result = try! Version3.decrypt(blob, with: sk).content

        XCTAssertEqual(message, result)
    }

    func testPublicKeyParity() {
        XCTAssertThrowsError(try Version3.AsymmetricPublicKey(hex: "02abb0916c4dcaf9fb7d42635e2ba95a592fc1d951b558b0463147fd62e44dddd6714aba4179374c5a0b4a0ff016fd6b0c"))

        XCTAssertNoThrow(try Version3.AsymmetricPublicKey(hex: "03abb0916c4dcaf9fb7d42635e2ba95a592fc1d951b558b0463147fd62e44dddd6714aba4179374c5a0b4a0ff016fd6b0c"))
    }
}
