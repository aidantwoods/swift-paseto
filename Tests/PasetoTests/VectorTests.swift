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
                return
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
    
    func testVersion2Local() throws {
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
                    return
                }
                
                decoded = decrypted
            case .none:
                let pk = try Version2.AsymmetricPublicKey(hex: test.publicKey!)
    
                guard let message = Message<Version2.Public>(test.token),
                      let verified = try? Version2.Public.verify(message, with: pk)
                else {
                    XCTAssertTrue(test.expectFail, test.name)
                    return
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

    func testVersion3Local() throws {
        let contents = try String(contentsOfFile: currentDir + "/TestVectors/v3.json")
            .data(using: .utf8)!

        let tests = try! JSONDecoder().decode(TestVectors.self, from: contents).tests

        // filter excludes public mode tests
        for test in tests.filter({$0.key != nil}) {
            let sk = try Version3.SymmetricKey(hex: test.key!)

            guard let message = Message<Version3.Local>(test.token),
                  let decrypted = try? Version3.Local.decrypt(
                    message,
                    with: sk,
                    implicit: test.implicitAssertion
                  )
            else {
                XCTAssertTrue(test.expectFail, test.name)
                return
            }

            XCTAssertFalse(test.expectFail, test.name)

            let expected = test.payload!

            XCTAssertEqual(String(bytes: decrypted.content), expected, test.name)

            let encrypted = try Version3.Local.encrypt(
                Package(expected, footer: test.footer),
                with: sk,
                implicit: test.implicitAssertion,
                unitTestNonce: Data(hex: test.nonce!)
            )

            XCTAssertEqual(encrypted.asString, test.token, test.name)
        }
    }
}


