//
//  Util+Extension.swift
//  Paseto
//
//  Created by Aidan Woods on 21/04/2018.
//

@testable import Paseto_Core

extension Util {
    public static func header(of string: String) -> Header? {
        // type arguements don't really matter here
        return Message<Version2.Local>.deconstruct(string)?.header
    }
}
