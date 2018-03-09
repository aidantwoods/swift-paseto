//
//  TokenTest.swift
//  PasetoTests
//
//  Created by Aidan Woods on 09/03/2018.
//

import XCTest
import Paseto

class TokenTest: XCTestCase {
    func testLocal() {
        let token = Token(claims: ["foo": "bar"])
            .replace(allowedVersions: [.v2])
            .replace(footer: "There be secrets within...")
            .add(claims: [
                "bar": "baz",
                "boo": "bop",
            ])

        let key = SymmetricKey<Version2>()

        let blob = token.encrypt(with: key)!
        let unsealedToken = blob.decrypt(with: key)!

        let expectedClaims = [
            "foo": "bar",
            "bar": "baz",
            "boo": "bop",
        ]
        XCTAssertEqual(unsealedToken.claims, expectedClaims)

        let expectedFooter = "There be secrets within..."
        XCTAssertEqual(unsealedToken.footer, expectedFooter)

        let expectedVersions: [Version] = [.v2]
        XCTAssertEqual(unsealedToken.allowedVersions, expectedVersions)
    }
}
