import XCTest
import Paseto
import Sodium

class Version4Test: XCTestCase {
    func testSign() {
        let sk = Version4.AsymmetricSecretKey()

        let message = "Hello world!"

        let signedBlob = Version4.sign(message, with: sk)

        let verified = try! Version4.verify(signedBlob, with: sk.publicKey).string

        XCTAssertEqual(message, verified)
    }

    func testEncrypt() {
        let sk = Version4.SymmetricKey()

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

        let encryptedBlob = Version4.encrypt(message, with: sk)

        let decrypted = try! Version4.decrypt(encryptedBlob, with: sk).string

        XCTAssertEqual(message, decrypted)
    }

    func testLargeData() {
        let sk = Version4.SymmetricKey()

        let message = Sodium().randomBytes.buf(length: Int(1 << 25))!

        let blob = Version4.encrypt(message, with: sk)

        let result = try! Version4.decrypt(blob, with: sk).content

        XCTAssertEqual(message, result)
    }

    func testReadmeExample() {
        let rawToken = "v4.public.eyJkYXRhIjoidGhpcyBpcyBhIHNpZ25lZCBtZXNzYWdlIiwiZXhwIjoiMjAyMi0wMS0wMVQwMDowMDowMCswMDowMCJ9v3Jt8mx_TdM2ceTGoqwrh4yDFn0XsHvvV_D0DtwQxVrJEBMl0F2caAdgnpKlt4p7xBnx1HcO-SPo8FPp214HDw.eyJraWQiOiJ6VmhNaVBCUDlmUmYyc25FY1Q3Z0ZUaW9lQTlDT2NOeTlEZmdMMVc2MGhhTiJ9"

        let key = try! Version4.AsymmetricPublicKey(
            hex: "1eb9dbbbbc047c03fd70604e0071f0987e16b28b757225c11f00415d0e20b1a2"
        )

        let parser = Parser<Version4.Public>(rules: [])
        let token = try! parser.verify(rawToken, with: key)

        XCTAssertEqual(
            ["data": "this is a signed message", "exp": "2022-01-01T00:00:00+00:00"],
            token.claims
        )

        XCTAssertEqual("{\"kid\":\"zVhMiPBP9fRf2snEcT7gFTioeA9COcNy9DfgL1W60haN\"}", token.footer)
    }

    func testDocExample() {
        let key = Version4.SymmetricKey()
        let message = Version4.encrypt("Hello world!", with: key)
        let pasetoString = message.asString
        let verySensitiveKeyMaterial = key.encode

        let importedKey = try! Version4.SymmetricKey(encoded: verySensitiveKeyMaterial)
        let importedMessage = Message<Version4.Local>(pasetoString)!
        let decrypted = try! Version4.decrypt(importedMessage, with: importedKey)

        XCTAssertEqual("Hello world!", decrypted.string!)
    }
}
