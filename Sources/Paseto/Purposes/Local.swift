//
//  Local.swift
//  Paseto
//
//  Created by Aidan Woods on 11/04/2018.
//

import Foundation

public protocol Local {
    associatedtype SymmetricKey: Paseto.SymmetricKey
    associatedtype Local: BaseLocal where SymmetricKey == Local.SymmetricKey

    static func encrypt(_: Package, with: SymmetricKey) throws -> Message<Local>

    static func decrypt(_: Message<Local>, with: SymmetricKey) throws -> Package
}

public extension Local {
    static func encrypt(
        _ data: BytesRepresentable,
        with key: SymmetricKey,
        footer: BytesRepresentable = Bytes()
    ) throws -> Message<Local> {
        return try encrypt(Package(data, footer: footer), with: key)
    }
}
