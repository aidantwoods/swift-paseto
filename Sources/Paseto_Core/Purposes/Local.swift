//
//  Local.swift
//  Paseto_Core
//
//  Created by Aidan Woods on 11/04/2018.
//

import Foundation

public protocol Local {
    associatedtype SymmetricKey: Paseto_Core.SymmetricKey
    associatedtype Local: BaseLocal where SymmetricKey == Local.SymmetricKey

    static func encrypt(_: Package, with: SymmetricKey) throws -> Message<Local>

    static func decrypt(_: Message<Local>, with: SymmetricKey) throws -> Package
}

public extension Local {
    static func encrypt(
        _ data: Data,
        with key: SymmetricKey,
        footer: Data = Data()
    ) throws -> Message<Local> {
        return try encrypt(Package(data, footer: footer), with: key)
    }

    static func encrypt(
        _ string: String,
        with key: SymmetricKey,
        footer: Data = Data()
    ) throws -> Message<Local> {
        return try encrypt(Data(string.utf8), with: key, footer: footer)
    }
}
