//
//  Version2Test.swift
//  PasetoTest
//
//  Created by Aidan Woods on 06/03/2018.
//

import XCTest
import Paseto
import Sodium

class Version2Test: XCTestCase {
    func testVerify() {
        let pk = try! AsymmetricPublicKey<Version2>(
            encoded: "Xq649QQaRMADs0XOWSuWj80ZHN4uqN7PfZuQ9NoqjBs"
        )

        let signedBlob = Blob<Signed>(
            "v2.public.dGVzdDUInakrW3fJBz_DRfy_IrgUj2UORbb72EJ0Z-"
                + "tufH0ZSUMCtij5-VsgbqoBzuNOpni5-J5CBHcVNTKVHzM79Ao"
        )!

        let message: String = Version2.verify(signedBlob, with: pk)!

        XCTAssertEqual(message , "test")
    }

    func testSign() {
        let sk = AsymmetricSecretKey<Version2>()

        let message = "Hello world!"

        let signedBlob = Version2.sign(message, with: sk)

        let verified: String = Version2.verify(signedBlob, with: sk.publicKey)!

        XCTAssertEqual(message, verified)
    }

    func testDecrypt() {
        let sk = try! SymmetricKey<Version2>(
            encoded: "EOIf5G5PXsHrm45-QV-NxEHRvyg-uw38BOIajl7slZ4"
        )

        let encryptedBlob = Blob<Encrypted>(
            "v2.local.iaODL67I7c1Fvg2BCsG6TWi58Y33d4fksk0Cut9hCp"
                + "vk0T-IXh5SlJPkPrjJ7cU"
        )!

        let message: String = Version2.decrypt(encryptedBlob, with: sk)!

        XCTAssertEqual(message, "Foobar!")
    }

    func testEncrypt() {
        let sk = SymmetricKey<Version2>()

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

        let encryptedBlob = Version2.encrypt(message, with: sk)

        let decrypted: String = Version2.decrypt(encryptedBlob, with: sk)!

        XCTAssertEqual(message, decrypted)
    }

    func testExample1() {
        let blob = Blob<Encrypted>(
            "v2.local.lClhzVOuseCWYep44qbA8rmXry66lUupyENijX37_I_z34EiOlfyuwqI"
                + "IhOjF-e9m2J-Qs17Gs-BpjpLlh3zf-J37n7YGHqMBV6G5xD2aeIKpck6rhf"
                + "wHpGF38L7ryYuzuUeqmPg8XozSfU4PuPp9o8.UGFyYWdvbiBJbml0aWF0aX"
                + "ZlIEVudGVycHJpc2Vz"
        )!

        let sk = SymmetricKey<Version2>(material: Sodium().utils.hex2bin(
            "707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f"
        )!)

        let expected = [
            "data": "this is a signed message",
            "expires": "2019-01-01T00:00:00+00:00"
        ]

        let expectedFooter = Data("Paragon Initiative Enterprises".utf8)

        let decrypted = try! Version2.decrypt(blob, with: sk)

        let result = try! JSONSerialization.jsonObject(with: decrypted)
            as! [String: String]

        XCTAssertEqual(expected, result)
        XCTAssertEqual(expectedFooter, blob.footer)
    }
}

