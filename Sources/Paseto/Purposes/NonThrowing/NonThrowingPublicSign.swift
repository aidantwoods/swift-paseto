//
//  NonThrowingPublicSign.swift
//  Paseto
//
//  Created by Aidan Woods on 19/04/2018.
//

import Foundation

public protocol NonThrowingPublicSign: Public {
    static func sign(_: Package, with: AsymmetricSecretKey) -> Message<Public>
}

public extension NonThrowingPublicSign {
    static func sign(
        _ data: BytesRepresentable,
        with key: AsymmetricSecretKey,
        footer: BytesRepresentable = Bytes()
    ) -> Message<Public> {
        return sign(Package(data, footer: footer), with: key)
    }
}

public extension NonThrowingPublicSign where
    Self: DeferredPublic,
    Public: NonThrowingPublicSign
{
    static func sign(
        _ package: Package,
        with key: AsymmetricSecretKey
    ) -> Message<Public> {
        return Public.sign(package, with: key)
    }
}
