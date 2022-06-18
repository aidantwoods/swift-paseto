import XCTest
@testable import Paseto
import Sodium
import Foundation


let fileArr = #file.components(separatedBy: "/")
let currentDir = fileArr[..<(fileArr.count - 1)].joined(separator: "/")

struct TestVectors: Codable {
    let name: String
    let tests: [TestVector]

    struct TestVector: Codable {
        let name: String
        let nonce: String?
        let key: String?
        let publicKey: String?
        let secretKey: String?
        let token: String
        let payload: String?
        let footer: String
        
        let expectFail: Bool
        let implicitAssertion: String
        
        enum CodingKeys: String, CodingKey {
            case expectFail = "expect-fail"
            case implicitAssertion = "implicit-assertion"
            case publicKey = "public-key"
            case secretKey = "secret-key"
            
            case name
            case nonce
            case key
            case token
            case payload
            case footer
        }
    }
}


class VectorTest: XCTestCase {
    func testVersion1Local() throws {
        let contents = try String(contentsOfFile: currentDir + "/TestVectors/v1.json")
            .data(using: .utf8)!
        
        let tests = try! JSONDecoder().decode(TestVectors.self, from: contents).tests

        // filter excludes public mode tests
        for test in tests.filter({$0.key != nil}) {
            let sk = try Version1.SymmetricKey(hex: test.key!)
            
            guard let message = Message<Version1.Local>(test.token),
                  let decrypted = try? Version1.Local.decrypt(message, with: sk)
            else {
                XCTAssertTrue(test.expectFail, test.name)
                continue
            }
            
            XCTAssertFalse(test.expectFail, test.name)
            
            let expected = test.payload!

            XCTAssertEqual(String(bytes: decrypted.content), expected, test.name)
            
            let encrypted = try Version1.Local.encrypt(
                Package(expected, footer: test.footer),
                with: sk,
                unitTestNonce: Data(hex: test.nonce!)
            )
            
            XCTAssertEqual(encrypted.asString, test.token, test.name)
        }
    }
    
    func testVersion2() throws {
        let contents = try String(contentsOfFile: currentDir + "/TestVectors/v2.json")
            .data(using: .utf8)!
        
        let tests = try! JSONDecoder().decode(TestVectors.self, from: contents).tests

        for test in tests {
            let decoded: Package
            
            switch test.key {
            case .some:
                let sk = try Version2.SymmetricKey(hex: test.key!)
                
                guard let message = Message<Version2.Local>(test.token),
                      let decrypted = try? Version2.Local.decrypt(message, with: sk)
                else {
                    XCTAssertTrue(test.expectFail, test.name)
                    continue
                }
                
                decoded = decrypted
            case .none:
                let pk = try Version2.AsymmetricPublicKey(hex: test.publicKey!)
    
                guard let message = Message<Version2.Public>(test.token),
                      let verified = try? Version2.Public.verify(message, with: pk)
                else {
                    XCTAssertTrue(test.expectFail, test.name)
                    continue
                }
                
                decoded = verified
            }

            XCTAssertFalse(test.expectFail, test.name)
            
            let expected = test.payload!

            XCTAssertEqual(String(bytes: decoded.content), expected, test.name)
            
            switch test.key {
            case .some:
                let sk = try Version2.SymmetricKey(hex: test.key!)
                
                let encrypted = Version2.Local.encrypt(
                    Package(expected, footer: test.footer),
                    with: sk,
                    unitTestNonce: Data(hex: test.nonce!)
                )
                
                XCTAssertEqual(encrypted.asString, test.token, test.name)
            case .none:
                let sk = try Version2.AsymmetricSecretKey(hex: test.secretKey!)
    
                let signed = Version2.Public.sign(
                    Package(expected, footer: test.footer),
                    with: sk
                )
                
                XCTAssertEqual(signed.asString, test.token, test.name)
            }
        }
    }

    func testVersion3() throws {
        let contents = try String(contentsOfFile: currentDir + "/TestVectors/v3.json")
            .data(using: .utf8)!

        let tests = try! JSONDecoder().decode(TestVectors.self, from: contents).tests

        for test in tests {
            let decoded: Package

            switch test.key {
            case .some:
                let sk = try Version3.SymmetricKey(hex: test.key!)

                guard let message = Message<Version3.Local>(test.token),
                      let decrypted = try? Version3.Local.decrypt(
                        message,
                        with: sk,
                        implicit: test.implicitAssertion
                      )
                else {
                    XCTAssertTrue(test.expectFail, test.name)
                    continue
                }

                decoded = decrypted
            case .none:
                if #available(macOS 11, iOS 14, watchOS 7, tvOS 14, macCatalyst 14, *) {
                    let pk = try Version3.AsymmetricPublicKey(hex: test.publicKey!)

                    guard let message = Message<Version3.Public>(test.token),
                          let verified = try? Version3.Public.verify(
                            message,
                            with: pk,
                            implicit: test.implicitAssertion
                          )
                    else {
                        XCTAssertTrue(test.expectFail, test.name)
                        continue
                    }

                    decoded = verified
                } else {
                    print("Skipping because current platform not supported...")
                    continue
                }
            }

            XCTAssertFalse(test.expectFail, test.name)

            let expected = test.payload!

            XCTAssertEqual(String(bytes: decoded.content), expected, test.name)

            switch test.key {
            case .some:
                let sk = try Version3.SymmetricKey(hex: test.key!)

                let encrypted = try Version3.Local.encrypt(
                    Package(expected, footer: test.footer),
                    with: sk,
                    implicit: test.implicitAssertion,
                    unitTestNonce: Data(hex: test.nonce!)
                )

                XCTAssertEqual(encrypted.asString, test.token, test.name)
            case .none:
                let sk = try Version3.AsymmetricSecretKey(hex: test.secretKey!)

                let signed = try Version3.Public.sign(
                    Package(expected, footer: test.footer),
                    with: sk,
                    implicit: test.implicitAssertion
                )

                let verified = try Version3.Public.verify(
                    signed,
                    with: sk.publicKey,
                    implicit: test.implicitAssertion
                )

                XCTAssertEqual(verified.string!, test.payload!)
                XCTAssertEqual(verified.footerString!, test.footer)
            }
        }
    }

    func testVersion4() throws {
        let contents = try String(contentsOfFile: currentDir + "/TestVectors/v4.json")
            .data(using: .utf8)!

        let tests = try! JSONDecoder().decode(TestVectors.self, from: contents).tests

        for test in tests {
            let decoded: Package

            switch test.key {
            case .some:
                let sk = try Version4.SymmetricKey(hex: test.key!)

                guard let message = Message<Version4.Local>(test.token),
                      let decrypted = try? Version4.Local.decrypt(
                        message,
                        with: sk,
                        implicit: test.implicitAssertion
                      )
                else {
                    XCTAssertTrue(test.expectFail, test.name)
                    continue
                }

                decoded = decrypted
            case .none:
                let pk = try Version4.AsymmetricPublicKey(hex: test.publicKey!)

                guard let message = Message<Version4.Public>(test.token),
                      let verified = try? Version4.Public.verify(
                        message,
                        with: pk,
                        implicit: test.implicitAssertion
                      )
                else {
                    XCTAssertTrue(test.expectFail, test.name)
                    continue
                }

                decoded = verified
            }

            XCTAssertFalse(test.expectFail, test.name)

            let expected = test.payload!

            XCTAssertEqual(String(bytes: decoded.content), expected, test.name)

            switch test.key {
            case .some:
                let sk = try Version4.SymmetricKey(hex: test.key!)

                let encrypted = Version4.Local.encrypt(
                    Package(expected, footer: test.footer),
                    with: sk,
                    implicit: test.implicitAssertion,
                    unitTestNonce: Data(hex: test.nonce!)
                )

                XCTAssertEqual(encrypted.asString, test.token, test.name)
            case .none:
                let sk = try Version4.AsymmetricSecretKey(hex: test.secretKey!)

                let signed = Version4.Public.sign(
                    Package(expected, footer: test.footer),
                    with: sk,
                    implicit: test.implicitAssertion
                )

                XCTAssertEqual(signed.asString, test.token, test.name)
            }
        }
    }
}


