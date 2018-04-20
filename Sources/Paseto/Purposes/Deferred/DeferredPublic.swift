//
//  DeferredPublic.swift
//  Paseto
//
//  Created by Aidan Woods on 18/04/2018.
//

public protocol DeferredPublic: Public {}

extension DeferredPublic {
    public static func sign(
        _ package: Package,
        with key: AsymmetricSecretKey
    ) throws -> Message<Public> {
        return try Public.sign(package, with: key)
    }

    public static func verify(
        _ message: Message<Public>,
        with key: AsymmetricPublicKey
    ) throws -> Package {
        return try Public.verify(message, with: key)
    }
}
