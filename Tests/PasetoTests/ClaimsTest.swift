import XCTest
import Paseto
import TypedJSON

class ClaimsTest: XCTestCase {
    func testAllClaimsPassV1() {
        var token = Token()

        token.audience = "a"
        token.jti = "b"
        token.issuer = "c"
        token.expiration = Date() + 60
        token.subject = "d"

        token.notBefore = Date() + 25
        token.issuedAt = Date()

        let key = Version1.SymmetricKey()

        let encrypted = try! token.encrypt(with: key)

        var parser = Parser<Version1.Local>()

        parser.addRule(Rules.forAudience("a"))
        parser.addRule(Rules.identifiedBy("b"))
        parser.addRule(Rules.issuedBy("c"))
        parser.addRule(Rules.notExpired())
        parser.addRule(Rules.subject("d"))
        parser.addRule(Rules.validAt(Date() + 30))

        let decrypted = try! parser.decrypt(encrypted, with: key)

        XCTAssertEqual(decrypted, token)
        XCTAssertEqual(String(bytes: decrypted.claimsJSON), String(bytes: token.claimsJSON))
    }

    func testAllClaimsPassV2() {
        var token = Token()

        token.audience = "a"
        token.jti = "b"
        token.issuer = "c"
        token.expiration = Date() + 60
        token.subject = "d"

        token.notBefore = Date() + 25
        token.issuedAt = Date()

        let key = Version2.SymmetricKey()
        let secretKey = Version2.AsymmetricSecretKey()

        let encrypted = try! token.encrypt(with: key)
        let signed = try! token.sign(with: secretKey)

        var parser = Parser<Version2.Local>()

        parser.addRule(Rules.forAudience("a"))
        parser.addRule(Rules.identifiedBy("b"))
        parser.addRule(Rules.issuedBy("c"))
        parser.addRule(Rules.notExpired())
        parser.addRule(Rules.subject("d"))
        parser.addRule(Rules.validAt(Date() + 30))

        let decrypted = try! parser.decrypt(encrypted, with: key)

        var parser2 = Parser<Version2.Public>()

        parser2.addRule(Rules.forAudience("a"))
        parser2.addRule(Rules.identifiedBy("b"))
        parser2.addRule(Rules.issuedBy("c"))
        parser2.addRule(Rules.notExpired())
        parser2.addRule(Rules.subject("d"))
        parser2.addRule(Rules.validAt(Date() + 30))

        let verified = try! parser2.verify(signed, with: secretKey.publicKey)

        XCTAssertEqual(verified, decrypted)
        XCTAssertEqual(verified, token)
        XCTAssertEqual(String(bytes: decrypted.claimsJSON), String(bytes: token.claimsJSON))
    }

    func testAllClaimsPassV3() {
        var token = Token()

        token.audience = "a"
        token.jti = "b"
        token.issuer = "c"
        token.expiration = Date() + 60
        token.subject = "d"

        token.notBefore = Date() + 25
        token.issuedAt = Date()

        let key = Version3.SymmetricKey()

        let encrypted = try! token.encrypt(with: key)

        var parser = Parser<Version3.Local>()

        parser.addRule(Rules.forAudience("a"))
        parser.addRule(Rules.identifiedBy("b"))
        parser.addRule(Rules.issuedBy("c"))
        parser.addRule(Rules.notExpired())
        parser.addRule(Rules.subject("d"))
        parser.addRule(Rules.validAt(Date() + 30))

        let decrypted = try! parser.decrypt(encrypted, with: key)

        XCTAssertEqual(decrypted, token)
        XCTAssertEqual(String(bytes: decrypted.claimsJSON), String(bytes: token.claimsJSON))
    }

    func testAllClaimsPassV4() {
        var token = Token()

        token.audience = "a"
        token.jti = "b"
        token.issuer = "c"
        token.expiration = Date() + 60
        token.subject = "d"

        token.notBefore = Date() + 25
        token.issuedAt = Date()

        let key = Version4.SymmetricKey()
        let secretKey = Version4.AsymmetricSecretKey()

        let encrypted = try! token.encrypt(with: key)
        let signed = try! token.sign(with: secretKey)

        var parser = Parser<Version4.Local>()

        parser.addRule(Rules.forAudience("a"))
        parser.addRule(Rules.identifiedBy("b"))
        parser.addRule(Rules.issuedBy("c"))
        parser.addRule(Rules.notExpired())
        parser.addRule(Rules.subject("d"))
        parser.addRule(Rules.validAt(Date() + 30))

        let decrypted = try! parser.decrypt(encrypted, with: key)

        var parser2 = Parser<Version4.Public>()

        parser2.addRule(Rules.forAudience("a"))
        parser2.addRule(Rules.identifiedBy("b"))
        parser2.addRule(Rules.issuedBy("c"))
        parser2.addRule(Rules.notExpired())
        parser2.addRule(Rules.subject("d"))
        parser2.addRule(Rules.validAt(Date() + 30))

        let verified = try! parser2.verify(signed, with: secretKey.publicKey)

        XCTAssertEqual(verified, decrypted)
        XCTAssertEqual(verified, token)
        XCTAssertEqual(String(bytes: decrypted.claimsJSON), String(bytes: token.claimsJSON))
    }

    func testFutureIat() {
        var token = Token()

        token.expiration = Date() + 60
        token.notBefore = Date() + 25
        token.issuedAt = Date() + 35

        let key = Version4.SymmetricKey()

        let encrypted = try! token.encrypt(with: key)

        var parser = Parser<Version4.Local>()

        parser.addRule(Rules.validAt(Date()))

        let decrypted = try? parser.decrypt(encrypted, with: key)
        XCTAssertNil(decrypted)
    }

    func testFutureNbf() {
        var token = Token()

        token.expiration = Date() + 60
        token.notBefore = Date() + 35
        token.issuedAt = Date()

        let key = Version4.SymmetricKey()

        let encrypted = try! token.encrypt(with: key)

        var parser = Parser<Version4.Local>()

        parser.addRule(Rules.validAt(Date()))

        let decrypted = try? parser.decrypt(encrypted, with: key)
        XCTAssertNil(decrypted)
    }

    func testPastExp() {
        var token = Token()

        token.expiration = Date() + 29
        token.notBefore = Date() + 25
        token.issuedAt = Date()

        let key = Version4.SymmetricKey()

        let encrypted = try! token.encrypt(with: key)

        var parser = Parser<Version4.Local>()

        parser.addRule(Rules.validAt(Date()))

        let decrypted = try? parser.decrypt(encrypted, with: key)
        XCTAssertNil(decrypted)
    }

    func testDefaultExpCheck() {
        var token = Token()

        token.expiration = Date() - 1

        let key = Version4.SymmetricKey()

        let encrypted = try! token.encrypt(with: key)

        let parser = Parser<Version4.Local>()

        let decrypted = try? parser.decrypt(encrypted, with: key)
        XCTAssertNil(decrypted)
    }
}
