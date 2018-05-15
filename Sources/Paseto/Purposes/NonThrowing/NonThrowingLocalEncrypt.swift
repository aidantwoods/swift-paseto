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
        _ data: BytesRepresentable,
        with key: SymmetricKey,
        footer: BytesRepresentable = Bytes()
    ) -> Message<Local> {
        return encrypt(Package(data, footer: footer), with: key)
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
