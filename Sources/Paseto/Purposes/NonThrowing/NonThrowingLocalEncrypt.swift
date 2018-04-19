//
//  NonThrowingLocalEncrypt.swift
//  Paseto
//
//  Created by Aidan Woods on 19/04/2018.
//

import Foundation

public protocol NonThrowingLocalEncrypt: Local {
    static func encrypt(_: Package, with: SymmetricKey) -> Message<Local>
}

public extension NonThrowingLocalEncrypt {
    static func encrypt(
        _ data: Data,
        with key: SymmetricKey,
        footer: Data = Data()
    ) -> Message<Local> {
        return encrypt(Package(data: data, footer: footer), with: key)
    }

    static func encrypt(
        _ string: String,
        with key: SymmetricKey,
        footer: Data = Data()
    ) -> Message<Local> {
        return encrypt(Data(string.utf8), with: key, footer: footer)
    }
}

public extension NonThrowingLocalEncrypt where
    Self: DeferredLocal,
    Local: NonThrowingLocalEncrypt
{
    static func encrypt(
        _ package: Package,
        with key: SymmetricKey
    ) -> Message<Local> {
        return Local.encrypt(package, with: key)
    }
}
