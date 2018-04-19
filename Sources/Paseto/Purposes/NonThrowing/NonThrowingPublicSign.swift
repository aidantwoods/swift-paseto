//
//  NonThrowingPublicSign.swift
//  Paseto
//
//  Created by Aidan Woods on 19/04/2018.
//

import Foundation

public protocol NonThrowingPublicSign: Public {
    static func sign(_: Package, with: SecretKey) -> Message<Public>
}

public extension NonThrowingPublicSign {
    static func sign(
        _ data: Data,
        with key: SecretKey,
        footer: Data = Data()
    ) -> Message<Public> {
        return sign(Package(data: data, footer: footer), with: key)
    }

    static func sign(
        _ string: String,
        with key: SecretKey,
        footer: Data = Data()
    ) -> Message<Public> {
        return sign(Data(string.utf8), with: key, footer: footer)
    }
}

public extension NonThrowingPublicSign where
    Self: DeferredPublic,
    Public: NonThrowingPublicSign
{
    static func sign(
        _ package: Package,
        with key: SecretKey
    ) -> Message<Public> {
        return Public.sign(package, with: key)
    }
}
