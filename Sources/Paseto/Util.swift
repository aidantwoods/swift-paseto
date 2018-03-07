//
//  Util.swift
//  Paseto
//
//  Created by Aidan Woods on 05/03/2018.
//

import Foundation

public enum Util {
    static func pae(_ pieces: [Data]) -> Data {
        return pieces.reduce(le64(pieces.count)) { $0 + le64($1.count) + $1 }
    }

    static func le64 (_ n: Int) -> Data { return le64(UInt64(n)) }

    static func le64 (_ n: UInt64) -> Data {
        // clear out the MSB
        let m = n & (UInt64.max >> 1)

        let codeToStr: (UInt64) -> String
            = String.init • UnicodeScalar.init • UInt8.init

        let str = (0..<8).reduce("") { $0 + codeToStr((m >> (8 * $1)) & 255) }

        return Data(str.utf8)
    }
}
