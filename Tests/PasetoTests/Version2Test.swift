//
//  Version2Test.swift
//  PasetoTest
//
//  Created by Aidan Woods on 06/03/2018.
//

import XCTest
@testable import Paseto
import Sodium

class Version2Test: XCTestCase {
    func testVerify() {
        let pk = try! AsymmetricPublicKey(
            encoded: "Xq649QQaRMADs0XOWSuWj80ZHN4uqN7PfZuQ9NoqjBs"
        )

        let signedBlob = Blob<SignedPayload>(
            serialised: "v2.public.dGVzdDUInakrW3fJBz_DRfy_IrgUj2UORbb72EJ0Z-"
            + "tufH0ZSUMCtij5-VsgbqoBzuNOpni5-J5CBHcVNTKVHzM79Ao"
        )!

        let message: String = Version2.verify(signedBlob, with: pk)!

        XCTAssertEqual(message , "test")
    }

    func testSign() {
        let sk = AsymmetricSecretKey(version: .v2)!

        let message = "Hello world!"

        let signedBlob = Version2.sign(message, with: sk)

        let verified: String = Version2.verify(signedBlob, with: sk.publicKey)!

        XCTAssertEqual(message, verified)
    }

    func testDecrypt() {
        let sk = try! SymmetricKey(
            encoded: "EOIf5G5PXsHrm45-QV-NxEHRvyg-uw38BOIajl7slZ4"
        )

        let encryptedBlob = Blob<EncryptedPayload>(
            serialised: "v2.local.iaODL67I7c1Fvg2BCsG6TWi58Y33d4fksk0Cut9hCp"
            + "vk0T-IXh5SlJPkPrjJ7cU"
        )!

        let message: String = Version2.decrypt(encryptedBlob, with: sk)!

        XCTAssertEqual(message, "Foobar!")
    }
}

