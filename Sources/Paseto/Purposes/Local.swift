//
//  Local.swift
//  Paseto
//
//  Created by Aidan Woods on 11/04/2018.
//

import Foundation

public protocol Local {
    associatedtype SymmetricKey: Paseto.SymmetricKey
    associatedtype Local: BaseLocal

    static func encrypt(_ data: Data, with key: SymmetricKey, footer: Data)
        throws -> Message<Local>

    static func decrypt(_ message: Message<Local>, with key: SymmetricKey)
        throws -> Data
}

public extension Local {
    static func encrypt(_ data: Data, with key: SymmetricKey)
        throws -> Message<Local>
    { return try encrypt(data, with: key, footer: Data()) }
}

public extension Local {
    static func encrypt(_ data: Data, with key: SymmetricKey, footer: Data = Data())
        -> Message<Local>?
    { return try? encrypt(data, with: key, footer: footer) }

    static func decrypt(_ message: Message<Local>, with key: SymmetricKey)
        -> Data?
    { return try? decrypt(message, with: key) }
}

public extension Local {
    static func encrypt(_ string: String, with key: SymmetricKey, footer: Data = Data())
        throws -> Message<Local>
    { return try encrypt(string, with: key, footer: footer) }
}

public extension Local {
    static func encrypt(_ string: String, with key: SymmetricKey, footer: Data = Data())
        -> Message<Local>?
    { return encrypt(Data(string.utf8), with: key, footer: footer) }

    static func decrypt(_ message: Message<Local>, with key: SymmetricKey)
        -> String?
    { return decrypt(message, with: key)?.utf8String }
}
