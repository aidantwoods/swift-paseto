//
//  Version1Test.swift
//  PasetoTest
//
//  Created by Aidan Woods on 06/03/2018.
//

import XCTest
import Paseto
import Sodium

class Version1Test: XCTestCase {
    func testDecrypt() {
        let sk = try! Version1.SymmetricKey(
            hex: "707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f"
        )

        let encryptedBlob = Message<Version1.Local>(
            "v1.local.rElw-WywOuwAqKC9Yao3YokSp7vx0YiUB9hLTnsVOYYTojmVaYumJSQt8aggtCaFKWyaodw5k-CUWhYKATopiabAl4OAmTxHCfm2E4NSPvrmMcmi8n-JcZ93HpcxC6rx_ps22vutv7iP7wf8QcSD1Mwx.Q3VvbiBBbHBpbnVz"
        )!

        let package = try! Version1.decrypt(encryptedBlob, with: sk)

        XCTAssertEqual(package.string!, "Love is stronger than hate or fear")
        XCTAssertEqual(package.footerString!, "Cuon Alpinus")
    }

    func testEncrypt() {
        let sk = Version1.SymmetricKey()

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

        let encrypted = try! Version1.encrypt(message, with: sk)

        let decrypted = try! Version1.decrypt(encrypted, with: sk).string

        XCTAssertEqual(message, decrypted)
    }

    func testLargeishData() {
        let sk = Version1.SymmetricKey()

        let message = Sodium().randomBytes.buf(length: Int(1 << 17))!

        let blob = try! Version1.encrypt(message, with: sk)

        let result: Data = try! Version1.decrypt(blob, with: sk).content

        XCTAssertEqual(message, result)
    }
}


