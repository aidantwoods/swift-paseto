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
        let sk = try! SymmetricKey<Version1>(
            hex: "707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f"
        )

        let encryptedBlob = Blob<Encrypted<Version1>>(
            "v1.local.rElw-WywOuwAqKC9Yao3YokSp7vx0YiUB9hLTnsVOYYTojmVaYumJSQt8aggtCaFKWyaodw5k-CUWhYKATopiabAl4OAmTxHCfm2E4NSPvrmMcmi8n-JcZ93HpcxC6rx_ps22vutv7iP7wf8QcSD1Mwx.Q3VvbiBBbHBpbnVz"
            )!

        let message: String = Version1.decrypt(encryptedBlob, with: sk)!

        XCTAssertEqual(message, "Love is stronger than hate or fear")
        XCTAssertEqual(encryptedBlob.footer, Data("Cuon Alpinus".utf8))
    }

    func testEncrypt() {
        let sk = SymmetricKey<Version1>()

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

        let encryptedBlob = Version1.encrypt(message, with: sk)!

        let decrypted: String = Version1.decrypt(encryptedBlob, with: sk)!

        XCTAssertEqual(message, decrypted)
    }

    func testLargeishData() {
        let sk = SymmetricKey<Version1>()

        let message = Sodium().randomBytes.buf(length: Int(1 << 15))!

        let blob = Version1.encrypt(message, with: sk)!

        let result: Data = Version1.decrypt(blob, with: sk)!

        XCTAssertEqual(message, result)
    }
}


