//
//  MetaMessage.swift
//  Paseto
//
//  Created by Aidan Woods on 10/03/2018.
//

import Foundation

/**
 * WARNING: This protocol assumes that the implementor is of type
 * Message<PayloadType> and WILL forcibly downcast to this type.
 * There is no sane reason to implement the protocol as a user.
 *
 * This protocol is contrived purely to side-step pointless restrictions on
 * recursion in where clauses.
 * All behaviour used is completely well defined, however it is not really in
 * the spirit of protocols to only have one possible implementor.
 * A protocol is used simply because protocol extensions have more freedom
 * than generic type extensions.
 *
 * Now for the: "why?!"
 *
 * Consider that Message was declared as:
 *
 *     struct Message<P: Payload> { ... }
 *
 * One cannot do something like:
 *
 *     extension Message where P == Signed<P.VersionType> { ... }
 *
 * because "Same-type constraint 'P' == 'Signed<P.VersionType>' is recursive".
 *
 * The only alternative is pointlessly raising the subtype to become a type
 * argument of Message directly, e.g.:
 *
 *     struct Message<P: Payload, V> where V == P.VersionType { ... }
 *
 * In this case, it is permitted to do:
 *
 *     extension Message where P == Signed<V> { ... }
 *
 * however we have to always explicitly duplicate generic parameters, e.g.:
 *
 *     let blob = Message<Signed<Version2>, Version2>
 *
 * This protocol forms so-called "Meta" version of a Message, which basically uses
 * the type raising described above, but allows us to compute this raised
 * type in a type-alias instead of having to carry it around in type arguments.
 * Note that this is not possible in a "real" type because type-aliases
 * (which are not also associated types) cannot be used in where extension
 * clauses.
 */
public protocol MetaMessage {
    associatedtype VersionType
    associatedtype PayloadType: Payload
        where PayloadType.VersionType == VersionType

    var header: Header { get }
    var footer: Data { get }
}

extension MetaMessage {
    func token(jsonData: Data) throws -> Token {
        guard let footer = self.footer.utf8String else {
            throw Message<PayloadType>.Exception.badEncoding(
                "Could not convert the footer to a UTF-8 string."
            )
        }

        return try Token(
            jsonData: jsonData,
            footer: footer,
            allowedVersions: [header.version]
        )
    }
}

extension MetaMessage where PayloadType == Signed<VersionType> {
    public func verify(with key: AsymmetricPublicKey<VersionType>) throws -> Token {
        let message = try VersionType.verify(
            self as! Message<PayloadType>,
            with: key
        )
        return try token(jsonData: message)
    }

    public func verify(with key: AsymmetricPublicKey<VersionType>) -> Token? {
        return try? verify(with: key)
    }
}

extension MetaMessage where PayloadType == Encrypted<VersionType> {
    public func decrypt(with key: SymmetricKey<VersionType>) throws -> Token {
        let message = try VersionType.decrypt(
            self as! Message<PayloadType>,
            with: key
        )
        return try token(jsonData: message)
    }

    public func decrypt(with key: SymmetricKey<VersionType>) -> Token? {
        return try? decrypt(with: key)
    }
}
