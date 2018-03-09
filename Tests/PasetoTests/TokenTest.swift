//
//  TokenTest.swift
//  PasetoTests
//
//  Created by Aidan Woods on 09/03/2018.
//

import XCTest
import Paseto

class TokenTest: XCTestCase {
    func testDecrypt() {
        let key = try! SymmetricKey<Version2>(
            encoded: "cHFyc3R1dnd4eXp7fH1-f4CBgoOEhYaHiImKi4yNjo8"
        )

        let blob = Blob<Encrypted>("""
            v2.local.lClhzVOuseCWYep44qbA8rmXry66lUupyENijX37_I_z34EiOlfyuwqII
            hOjF-e9m2J-Qs17Gs-BpjpLlh3zf-J37n7YGHqMBV6G5xD2aeIKpck6rhfwHpGF38L
            7ryYuzuUeqmPg8XozSfU4PuPp9o8.UGFyYWdvbiBJbml0aWF0aXZlIEVudGVycHJpc
            2Vz
            """.replacingOccurrences(of: "\n", with: "")
        )!

        let token = blob.decrypt(with: key)!

        let expectedClaims = [
            "data": "this is a signed message",
            "expires": "2019-01-01T00:00:00+00:00",
        ]
        XCTAssertEqual(expectedClaims, token.claims)

        let expectedFooter = "Paragon Initiative Enterprises"
        XCTAssertEqual(expectedFooter, token.footer)

        XCTAssertEqual(type(of: key).version, .v2)
    }

    func testEncrypt() {
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
