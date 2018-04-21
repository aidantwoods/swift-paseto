//
//  Version1VectorTest.swift
//  PasetoTests
//
//  Created by Aidan Woods on 10/03/2018.
//

import XCTest
@testable import Paseto_V1
import Sodium

class Version1VectorTest: XCTestCase {
    let symmetricKey = try! Version1.SymmetricKey(
        hex: "707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f"
    )

    let nullKey = try! Version1.SymmetricKey(
        hex: String(repeating: "00", count: 32)
    )

    let fullKey = try! Version1.SymmetricKey(
        hex: String(repeating: "ff", count: 32)
    )

    func testEncrypt() {
        let nonce1 = Data(String(repeating: "\0", count: 32).utf8)

        let emptyMessage = Data()
        let emptyFooter = Data()

        XCTAssertEqual(
            "v1.local.bB8u6Tj60uJL2RKYR0OCyiGMdds9g-EUs9Q2d3bRTTXyNMehtdOLJS_vq4YzYdaZ6vwItmpjx-Lt3AtVanBmiMyzFyqJMHCaWVMpEMUyxUg",
            try! Version1.Local.encrypt(
                emptyMessage, with: nullKey, footer: emptyFooter, unitTestNonce: nonce1
            ).asString
        )

        XCTAssertEqual(
            "v1.local.bB8u6Tj60uJL2RKYR0OCyiGMdds9g-EUs9Q2d3bRTTWgetvu2STfe7gxkDpAOk_IXGmBeea4tGW6HsoH12oKElAWap57-PQMopNurtEoEdk",
            try! Version1.Local.encrypt(
                emptyMessage, with: fullKey, footer: emptyFooter, unitTestNonce: nonce1
            ).asString
        )

        XCTAssertEqual(
            "v1.local.bB8u6Tj60uJL2RKYR0OCyiGMdds9g-EUs9Q2d3bRTTV8OmiMvoZgzer20TE8kb3R0QN9Ay-ICSkDD1-UDznTCdBiHX1fbb53wdB5ng9nCDY",
            try! Version1.Local.encrypt(
                emptyMessage, with: symmetricKey, footer: emptyFooter, unitTestNonce: nonce1
            ).asString
        )

        let footer1 = Data("Cuon Alpinus".utf8)

        XCTAssertEqual(
            "v1.local.bB8u6Tj60uJL2RKYR0OCyiGMdds9g-EUs9Q2d3bRTTVhyXOB4vmrFm9GvbJdMZGArV5_10Kxwlv4qSb-MjRGgFzPg00-T2TCFdmc9BMvJAA.Q3VvbiBBbHBpbnVz",
            try! Version1.Local.encrypt(
                emptyMessage, with: nullKey, footer: footer1, unitTestNonce: nonce1
            ).asString
        )

        XCTAssertEqual(
            "v1.local.bB8u6Tj60uJL2RKYR0OCyiGMdds9g-EUs9Q2d3bRTTVna3s7WqUwfQaVM8ddnvjPkrWkYRquX58-_RgRQTnHn7hwGJwKT3H23ZDlioSiJeo.Q3VvbiBBbHBpbnVz",
            try! Version1.Local.encrypt(
                emptyMessage, with: fullKey, footer: footer1, unitTestNonce: nonce1
            ).asString
        )

        XCTAssertEqual(
            "v1.local.bB8u6Tj60uJL2RKYR0OCyiGMdds9g-EUs9Q2d3bRTTW9MRfGNyfC8vRpl8xsgnsWt-zHinI9bxLIVF0c6INWOv0_KYIYEaZjrtumY8cyo7M.Q3VvbiBBbHBpbnVz",
            try! Version1.Local.encrypt(
                emptyMessage, with: symmetricKey, footer: footer1, unitTestNonce: nonce1
            ).asString
        )

        let message1 = Data("Love is stronger than hate or fear".utf8)

        XCTAssertEqual(
            "v1.local.N9n3wL3RJUckyWdg4kABZeMwaAfzNT3B64lhyx7QA45LtwQCqG8LYmNfBHIX-4Uxfm8KzaYAUUHqkxxv17MFxsEvk-Ex67g9P-z7EBFW09xxSt21Xm1ELB6pxErl4RE1gGtgvAm9tl3rW2-oy6qHlYx2",
            try! Version1.Local.encrypt(
                message1, with: nullKey, footer: emptyFooter, unitTestNonce: nonce1
            ).asString
        )

        XCTAssertEqual(
            "v1.local.N9n3wL3RJUckyWdg4kABZeMwaAfzNT3B64lhyx7QA47lQ79wMmeM7sC4c0-BnsXzIteEQQBQpu_FyMznRnzYg4gN-6Kt50rXUxgPPfwDpOr3lUb5U16RzIGrMNemKy0gRhfKvAh1b8N57NKk93pZLpEz",
            try! Version1.Local.encrypt(
                message1, with: fullKey, footer: emptyFooter, unitTestNonce: nonce1
            ).asString
        )

        XCTAssertEqual(
            "v1.local.N9n3wL3RJUckyWdg4kABZeMwaAfzNT3B64lhyx7QA47hvAicYf1zfZrxPrLeBFdbEKO3JRQdn3gjqVEkR1aXXttscmmZ6t48tfuuudETldFD_xbqID74_TIDO1JxDy7OFgYI_PehxzcapQ8t040Fgj9k",
            try! Version1.Local.encrypt(
                message1, with: symmetricKey, footer: emptyFooter, unitTestNonce: nonce1
            ).asString
        )

        let nonce2 = Sodium().utils.hex2bin(
            "26f7553354482a1d91d4784627854b8da6b8042a7966523c2b404e8dbbe7f7f2"
        )

        XCTAssertEqual(
            "v1.local.rElw-WywOuwAqKC9Yao3YokSp7vx0YiUB9hLTnsVOYbivwqsESBnr82_ZoMFFGzolJ6kpkOihkulB4K_JhfMHoFw4E9yCR6ltWX3e9MTNSud8mpBzZiwNXNbgXBLxF_Igb5Ixo_feIonmCucOXDlLVUT.Q3VvbiBBbHBpbnVz",
            try! Version1.Local.encrypt(
                message1, with: nullKey, footer: footer1, unitTestNonce: nonce2
            ).asString
        )

        XCTAssertEqual(
            "v1.local.rElw-WywOuwAqKC9Yao3YokSp7vx0YiUB9hLTnsVOYZ8rQTA12SNb9cY8jVtVyikY2jj_tEBzY5O7GJsxb5MdQ6cMSnDz2uJGV20vhzVDgvkjdEcN9D44VaHid26qy1_1YlHjU6pmyTmJt8WT21LqzDl.Q3VvbiBBbHBpbnVz",
            try! Version1.Local.encrypt(
                message1, with: fullKey, footer: footer1, unitTestNonce: nonce2
            ).asString
        )

        XCTAssertEqual(
            "v1.local.rElw-WywOuwAqKC9Yao3YokSp7vx0YiUB9hLTnsVOYYTojmVaYumJSQt8aggtCaFKWyaodw5k-CUWhYKATopiabAl4OAmTxHCfm2E4NSPvrmMcmi8n-JcZ93HpcxC6rx_ps22vutv7iP7wf8QcSD1Mwx.Q3VvbiBBbHBpbnVz",
            try! Version1.Local.encrypt(
                message1, with: symmetricKey, footer: footer1, unitTestNonce: nonce2
            ).asString
        )
    }
}
