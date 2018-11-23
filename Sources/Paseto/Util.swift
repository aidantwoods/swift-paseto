//
//  Util.swift
//  Paseto
//
//  Created by Aidan Woods on 05/03/2018.
//

import Foundation

public enum Util {
    static func pae(_ pieces: [BytesRepresentable]) -> Bytes {
        return pieces.reduce(le64(pieces.count)) {
            $0 + le64($1.bytes.count) + $1.bytes
        }
    }

    static func le64 (_ n: Int) -> Bytes { return le64(UInt64(n)) }

    static func le64 (_ n: UInt64) -> Bytes {
        // clear out the MSB
        let m = n & (UInt64.max >> 1)

        return (0..<8).map{ m >> (8 * $0) & 255 }.map(UInt8.init)
    }

    public static func header(of string: String) -> Header? {
        // type arguments don't really matter here
        return Message<Version2.Local>.deconstruct(string)?.header
    }

    static func random(length: Int) -> Bytes {
        return sodium.randomBytes.buf(length: length)!
    }

    static func equals(_ lhs: Bytes, _ rhs: Bytes) -> Bool {
        return sodium.utils.equals(lhs, rhs)
    }
}
