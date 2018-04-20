//
//  Version2VectorTest.swift
//  PasetoTests
//
//  Created by Aidan Woods on 09/03/2018.
//

import XCTest
@testable import Paseto
import Sodium

class Version2VectorTest: XCTestCase {
    let symmetricKey = try! Version2.SymmetricKey(
        hex: "707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f"
    )

    let nullKey = try! Version2.SymmetricKey(
        hex: String(repeating: "00", count: 32)
    )

    let fullKey = try! Version2.SymmetricKey(
        hex: String(repeating: "ff", count: 32)
    )

    let privateKey = try! Version2.AsymmetricSecretKey(
        hex: "b4cbfb43df4ce210727d953e4a713307fa19bb7d9f85041438d9e11b942a3774"
            + "1eb9dbbbbc047c03fd70604e0071f0987e16b28b757225c11f00415d0e20b1a2"
    )

    let publicKey = try! Version2.AsymmetricPublicKey(
        hex: "1eb9dbbbbc047c03fd70604e0071f0987e16b28b757225c11f00415d0e20b1a2"
    )

    func testEncrypt() {
        let nonce1 = Data(String(repeating: "\0", count: 24).utf8)

        let emptyMessage = Data()
        let emptyFooter = Data()

        XCTAssertEqual(
            "v2.local.driRNhM20GQPvlWfJCepzh6HdijAq-yNUtKpdy5KXjKfpSKrOlqQvQ",
            Version2.Local.encrypt(
                emptyMessage, with: nullKey, footer: emptyFooter, unitTestNonce: nonce1
            ).asString
        )

        XCTAssertEqual(
            "v2.local.driRNhM20GQPvlWfJCepzh6HdijAq-yNSOvpveyCsjPYfe9mtiJDVg",
            Version2.Local.encrypt(
                emptyMessage, with: fullKey, footer: emptyFooter, unitTestNonce: nonce1
            ).asString
        )

        XCTAssertEqual(
            "v2.local.driRNhM20GQPvlWfJCepzh6HdijAq-yNkIWACdHuLiJiW16f2GuGYA",
            Version2.Local.encrypt(
                emptyMessage, with: symmetricKey, footer: emptyFooter, unitTestNonce: nonce1
            ).asString
        )

        let footer1  = Data("Cuon Alpinus".utf8)

        XCTAssertEqual(
            "v2.local.driRNhM20GQPvlWfJCepzh6HdijAq-yNfzz6yGkE4ZxojJAJwKLfvg.Q3VvbiBBbHBpbnVz",
            Version2.Local.encrypt(
                emptyMessage, with: nullKey, footer: footer1, unitTestNonce: nonce1
            ).asString
        )

        XCTAssertEqual(
            "v2.local.driRNhM20GQPvlWfJCepzh6HdijAq-yNJbTJxAGtEg4ZMXY9g2LSoQ.Q3VvbiBBbHBpbnVz",
            Version2.Local.encrypt(
                emptyMessage, with: fullKey, footer: footer1, unitTestNonce: nonce1
            ).asString
        )

        XCTAssertEqual(
            "v2.local.driRNhM20GQPvlWfJCepzh6HdijAq-yNreCcZAS0iGVlzdHjTf2ilg.Q3VvbiBBbHBpbnVz",
            Version2.Local.encrypt(
                emptyMessage, with: symmetricKey, footer: footer1, unitTestNonce: nonce1
            ).asString
        )

        let message1 = Data("Love is stronger than hate or fear".utf8)

        XCTAssertEqual(
            "v2.local.BEsKs5AolRYDb_O-bO-lwHWUextpShFSvu6cB-KuR4wR9uDMjd45cPiOF0zxb7rrtOB5tRcS7dWsFwY4ONEuL5sWeunqHC9jxU0",
            Version2.Local.encrypt(
                message1, with: nullKey, footer: emptyFooter, unitTestNonce: nonce1
            ).asString
        )

        XCTAssertEqual(
            "v2.local.BEsKs5AolRYDb_O-bO-lwHWUextpShFSjvSia2-chHyMi4LtHA8yFr1V7iZmKBWqzg5geEyNAAaD6xSEfxoET1xXqahe1jqmmPw",
            Version2.Local.encrypt(
                message1, with: fullKey, footer: emptyFooter, unitTestNonce: nonce1
            ).asString
        )

        XCTAssertEqual(
            "v2.local.BEsKs5AolRYDb_O-bO-lwHWUextpShFSXlvv8MsrNZs3vTSnGQG4qRM9ezDl880jFwknSA6JARj2qKhDHnlSHx1GSCizfcF019U",
            Version2.Local.encrypt(
                message1, with: symmetricKey, footer: emptyFooter, unitTestNonce: nonce1
            ).asString
        )

        let nonce2 = Sodium().utils.hex2bin(
            "45742c976d684ff84ebdc0de59809a97cda2f64c84fda19b"
        )

        XCTAssertEqual(
            "v2.local.FGVEQLywggpvH0AzKtLXz0QRmGYuC6yvbcqXgWxM3vJGrJ9kWqquP61Xl7bz4ZEqN5XwH7xyzV0QqPIo0k52q5sWxUQ4LMBFFso.Q3VvbiBBbHBpbnVz",
            Version2.Local.encrypt(
                message1, with: nullKey, footer: footer1, unitTestNonce: nonce2
            ).asString
        )

        XCTAssertEqual(
            "v2.local.FGVEQLywggpvH0AzKtLXz0QRmGYuC6yvZMW3MgUMFplQXsxcNlg2RX8LzFxAqj4qa2FwgrUdH4vYAXtCFrlGiLnk-cHHOWSUSaw.Q3VvbiBBbHBpbnVz",
            Version2.Local.encrypt(
                message1, with: fullKey, footer: footer1, unitTestNonce: nonce2
            ).asString
        )

        XCTAssertEqual(
            "v2.local.FGVEQLywggpvH0AzKtLXz0QRmGYuC6yvl05z9GIX0cnol6UK94cfV77AXnShlUcNgpDR12FrQiurS8jxBRmvoIKmeMWC5wY9Y6w.Q3VvbiBBbHBpbnVz",
            Version2.Local.encrypt(
                message1, with: symmetricKey, footer: footer1, unitTestNonce: nonce2
            ).asString
        )

        let message2 = Data("{\"data\":\"this is a signed message\",\"expires\":\"2019-01-01T00:00:00+00:00\"}".utf8)

        let footer2 = Data("Paragon Initiative Enterprises".utf8)

        XCTAssertEqual(
            "v2.local.lClhzVOuseCWYep44qbA8rmXry66lUupyENijX37_I_z34EiOlfyuwqIIhOjF-e9m2J-Qs17Gs-BpjpLlh3zf-J37n7YGHqMBV6G5xD2aeIKpck6rhfwHpGF38L7ryYuzuUeqmPg8XozSfU4PuPp9o8.UGFyYWdvbiBJbml0aWF0aXZlIEVudGVycHJpc2Vz",
            Version2.Local.encrypt(
                message2, with: symmetricKey, footer: footer2, unitTestNonce: nonce2
            ).asString
        )
    }

    func testSignVectors() {
        XCTAssertEqual(
        "v2.public.xnHHprS7sEyjP5vWpOvHjAP2f0HER7SWfPuehZ8QIctJRPTrlZLtRCk9_iNdugsrqJoGaO4k9cDBq3TOXu24AA",
            Version2.sign("", with: privateKey).asString
        )

        XCTAssertEqual(
            "v2.public.Qf-w0RdU2SDGW_awMwbfC0Alf_nd3ibUdY3HigzU7tn_4MPMYIKAJk_J_yKYltxrGlxEdrWIqyfjW81njtRyDw.Q3VvbiBBbHBpbnVz",
            Version2.sign("", with: privateKey, footer: Data("Cuon Alpinus".utf8)).asString
        )

        XCTAssertEqual(
            "v2.public.RnJhbmsgRGVuaXMgcm9ja3NBeHgns4TLYAoyD1OPHww0qfxHdTdzkKcyaE4_fBF2WuY1JNRW_yI8qRhZmNTaO19zRhki6YWRaKKlCZNCNrQM",
            Version2.sign("Frank Denis rocks", with: privateKey).asString
        )

        XCTAssertEqual(
            "v2.public.RnJhbmsgRGVuaXMgcm9ja3NBeHgns4TLYAoyD1OPHww0qfxHdTdzkKcyaE4_fBF2WuY1JNRW_yI8qRhZmNTaO19zRhki6YWRaKKlCZNCNrQM",
            Version2.sign("Frank Denis rocks", with: privateKey).asString
        )

        XCTAssertEqual(
            "v2.public.RnJhbmsgRGVuaXMgcm9ja3qIOKf8zCok6-B5cmV3NmGJCD6y3J8fmbFY9KHau6-e9qUICrGlWX8zLo-EqzBFIT36WovQvbQZq4j6DcVfKCML",
            Version2.sign("Frank Denis rockz", with: privateKey).asString
        )


        XCTAssertEqual(
            "v2.public.RnJhbmsgRGVuaXMgcm9ja3O7MPuu90WKNyvBUUhAGFmi4PiPOr2bN2ytUSU-QWlj8eNefki2MubssfN1b8figynnY0WusRPwIQ-o0HSZOS0F.Q3VvbiBBbHBpbnVz",
            Version2.sign("Frank Denis rocks", with: privateKey, footer: Data("Cuon Alpinus".utf8)).asString
        )

        let message = Data("{\"data\":\"this is a signed message\",\"expires\":\"2019-01-01T00:00:00+00:00\"}".utf8)

        let footer = Data("Paragon Initiative Enterprises".utf8)

        XCTAssertEqual(
            "v2.public.eyJkYXRhIjoidGhpcyBpcyBhIHNpZ25lZCBtZXNzYWdlIiwiZXhwaXJlcyI6IjIwMTktMDEtMDFUMDA6MDA6MDArMDA6MDAifSUGY_L1YtOvo1JeNVAWQkOBILGSjtkX_9-g2pVPad7_SAyejb6Q2TDOvfCOpWYH5DaFeLOwwpTnaTXeg8YbUwI",
            Version2.sign(message, with: privateKey).asString
        )

        XCTAssertEqual(
            "v2.public.eyJkYXRhIjoidGhpcyBpcyBhIHNpZ25lZCBtZXNzYWdlIiwiZXhwaXJlcyI6IjIwMTktMDEtMDFUMDA6MDA6MDArMDA6MDAifcMYjoUaEYXAtzTDwlcOlxdcZWIZp8qZga3jFS8JwdEjEvurZhs6AmTU3bRW5pB9fOQwm43rzmibZXcAkQ4AzQs.UGFyYWdvbiBJbml0aWF0aXZlIEVudGVycHJpc2Vz",
            Version2.sign(message, with: privateKey, footer: footer).asString
        )
    }
}
