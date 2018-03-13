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

        return Data((0..<8).map { m >> (8 * $0) & 255 }.map(UInt8.init))
    }

    public static func header(of string: String) -> Header? {
        // type arguements don't really matter here
        return Blob<Encrypted<Version2>>.deconstruct(string)?.header
    }
}
