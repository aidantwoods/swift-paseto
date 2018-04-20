//
//  DeferredLocal.swift
//  Paseto
//
//  Created by Aidan Woods on 18/04/2018.
//

public protocol DeferredLocal: Local {}

extension DeferredLocal {
    public static func encrypt(
        _ package: Package,
        with key: SymmetricKey
    ) throws -> Message<Local> {
        return try Local.encrypt(package, with: key)
    }

    public static func decrypt(
        _ message: Message<Local>,
        with key: SymmetricKey
    ) throws -> Package {
        return try Local.decrypt(message, with: key)
    }
}
