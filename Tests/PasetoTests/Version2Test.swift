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

        let message = try! Version2.verify(signedBlob, with: pk)

        XCTAssertEqual(message.utf8String! , "test")
    }

    func testSign() {
        let sk = AsymmetricSecretKey(version: .v2)!

        let message = "Hello world!"

        let signedBlob = Version2.sign(Data(message.utf8), with: sk)

        let verified = try! Version2.verify(signedBlob, with: sk.publicKey)

        XCTAssertEqual(message, verified.utf8String!)
    }
}

