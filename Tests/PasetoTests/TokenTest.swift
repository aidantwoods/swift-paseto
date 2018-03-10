//
//  TokenTest.swift
//  PasetoTests
//
//  Created by Aidan Woods on 09/03/2018.
//

import XCTest
import Paseto

class TokenTest: XCTestCase {
    func testV1Decrypt() {
        // setup
        let message = """
            v1.local.RyoRvI1w3vHN80SRZrBmCugFk4bKaSzSFHM6lbCyTa7_b3wRN8ujJMIt
            IQ3bgXOYosKt8DJP98VBnKzKtA_W5eYGdPrp2SjbaMDz22M1Xd3Jhjgcl_Rl7Ktwv
            g7EWR7Lr00znpJFNSOsS0D60RyFFZUtGFt4XWN6lgX02MdjJua-quukaV1OcXDuIb
            U9ttZ0s-pQd0d5tuu9.UGFyYWdvbiBJbml0aWF0aXZlIEVudGVycHJpc2Vz
            """.replacingOccurrences(of: "\n", with: "")

        // load a version1 symmetric key
        let key = try! SymmetricKey<Version1>(
            encoded: "cHFyc3R1dnd4eXp7fH1-f4CBgoOEhYaHiImKi4yNjo8"
        )

        // we expect our message is encrypted (i.e. a "local" purpose)
        let blob = Blob<Encrypted>(message)!
        // encrypted blobs are specialised to have a decrypt method
        // to obtain a token, given a symmetric key
        let token = blob.decrypt(with: key)!

        // test our token is what we expected
        let expectedClaims = [
            "data": "this is a signed message",
            "expires": "2019-01-01T00:00:00+00:00",
        ]
        XCTAssertEqual(expectedClaims, token.claims)

        let expectedFooter = "Paragon Initiative Enterprises"
        XCTAssertEqual(expectedFooter, token.footer)

        // allowed versions should be identical to that of the type of key used
        // for decryption
        XCTAssertEqual([type(of: key).version], token.allowedVersions)
    }

    func testV2Decrypt() {
        // setup
        let message = """
            v2.local.lClhzVOuseCWYep44qbA8rmXry66lUupyENijX37_I_z34EiOlfyuwqII
            hOjF-e9m2J-Qs17Gs-BpjpLlh3zf-J37n7YGHqMBV6G5xD2aeIKpck6rhfwHpGF38L
            7ryYuzuUeqmPg8XozSfU4PuPp9o8.UGFyYWdvbiBJbml0aWF0aXZlIEVudGVycHJpc
            2Vz
            """.replacingOccurrences(of: "\n", with: "")

        // load a version2 symmetric key
        let key = try! SymmetricKey<Version2>(
            encoded: "cHFyc3R1dnd4eXp7fH1-f4CBgoOEhYaHiImKi4yNjo8"
        )

        // we expect our message is encrypted (i.e. a "local" purpose)
        let blob = Blob<Encrypted>(message)!
        // encrypted blobs are specialised to have a decrypt method
        // to obtain a token, given a symmetric key
        let token = blob.decrypt(with: key)!

        // test our token is what we expected
        let expectedClaims = [
            "data": "this is a signed message",
            "expires": "2019-01-01T00:00:00+00:00",
        ]
        XCTAssertEqual(expectedClaims, token.claims)

        let expectedFooter = "Paragon Initiative Enterprises"
        XCTAssertEqual(expectedFooter, token.footer)

        // allowed versions should be identical to that of the type of key used
        // for decryption
        XCTAssertEqual([type(of: key).version], token.allowedVersions)
    }

    func testV1Encrypt() {
        let token = Token(claims: ["foo": "bar"])
            .replace(allowedVersions: [.v1])
            .replace(footer: "There be secrets within...")
            .add(claims: [
                "bar": "baz",
                "boo": "bop",
            ])

        let key = SymmetricKey<Version1>()

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

        let expectedVersions: [Version] = [.v1]
        XCTAssertEqual(unsealedToken.allowedVersions, expectedVersions)
    }

    func testV2Encrypt() {
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

    func testV2Sign() {
        let token = Token(claims: ["foo": "bar"])
            .replace(allowedVersions: [.v2])
            .replace(footer: "There be secrets within...")
            .add(claims: [
                "bar": "baz",
                "boo": "bop",
            ])

        let key = AsymmetricSecretKey<Version2>()

        let blob = token.sign(with: key)!
        let unsealedToken = blob.verify(with: key.publicKey)!

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

    func testV2Verify() {
        // setup
        let message = """
            v2.public.eyJleHAiOiIyMDM5LTAxLTAxVDAwOjAwOjAwKzAwOjAwIiwiZGF0YSI6
            InRoaXMgaXMgYSBzaWduZWQgbWVzc2FnZSJ91gC7-jCWsN3mv4uJaZxZp0btLJgcyV
            wL-svJD7f4IHyGteKe3HTLjHYTGHI1MtCqJ-ESDLNoE7otkIzamFskCA
            """.replacingOccurrences(of: "\n", with: "")

        // load a version2 symmetric key
        let key = try! AsymmetricPublicKey<Version2>(
            encoded: "ETJDl_U1ViF41T_1OOSdWhYiQpcFVrTt2VDIfH2GZIo"
        )

        // we expect our message is encrypted (i.e. a "local" purpose)
        let blob = Blob<Signed>(message)!
        // encrypted blobs are specialised to have a decrypt method
        // to obtain a token, given a symmetric key
        let token = blob.verify(with: key)!

        // test our token is what we expected
        let expectedClaims = [
            "data": "this is a signed message",
            "exp": "2039-01-01T00:00:00+00:00",
        ]
        XCTAssertEqual(expectedClaims, token.claims)

        let expectedFooter = ""
        XCTAssertEqual(expectedFooter, token.footer)

        // allowed versions should be identical to that of the type of key used
        // for decryption
        XCTAssertEqual([type(of: key).version], token.allowedVersions)
    }
}
