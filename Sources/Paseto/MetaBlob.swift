//
//  MetaBlob.swift
//  Paseto
//
//  Created by Aidan Woods on 10/03/2018.
//

import Foundation

/**
 * WARNING: This protocol assumes that the implementor is of type
 * Blob<PayloadType> and WILL forcibly downcast to this type.
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
 * Consider that Blob was declared as:
 *
 *     struct Blob<P: Payload> { ... }
 *
 * One cannot do something like:
 *
 *     extension Blob where P == Signed<P.VersionType> { ... }
 *
 * because "Same-type constraint 'P' == 'Signed<P.VersionType>' is recursive".
 *
 * The only alternative is pointlessly raising the subtype to become a type
 * argument of Blob directly, e.g.:
 *
 *     struct Blob<P: Payload, V> where V == P.VersionType { ... }
 *
 * In this case, it is permitted to do:
 *
 *     extension Blob where P == Signed<V> { ... }
 *
 * however we have to always explicitly duplicate generic parameters, e.g.:
 *
 *     let blob = Blob<Signed<Version2>, Version2>
 *
 * This protocol forms so-called "Meta" version of a Blob, which basically uses
 * the type raising described above, but allows us to compute this raised
 * type in a type-alias instead of having to carry it around in type arguments.
 * Note that this is not possible in a "real" type because type-aliases
 * (which are not also associated types) cannot be used in where extension
 * clauses.
 */
public protocol MetaBlob {
    associatedtype VersionType
    associatedtype PayloadType: Payload
        where PayloadType.VersionType == VersionType

    var header: Header { get }
    var footer: Data { get }
}

extension MetaBlob {
    func token(jsonData: Data) throws -> Token {
        guard let footer = self.footer.utf8String else {
            throw Blob<PayloadType>.Exception.badEncoding(
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

extension MetaBlob where PayloadType == Signed<VersionType> {
    public func verify(with key: AsymmetricPublicKey<VersionType>) throws -> Token {
        let message = try VersionType.verify(
            self as! Blob<PayloadType>,
            with: key
        )
        return try token(jsonData: message)
    }

    public func verify(with key: AsymmetricPublicKey<VersionType>) -> Token? {
        return try? verify(with: key)
    }
}

extension MetaBlob where PayloadType == Encrypted<VersionType> {
    public func decrypt(with key: SymmetricKey<VersionType>) throws -> Token {
        let message = try VersionType.decrypt(
            self as! Blob<PayloadType>,
            with: key
        )
        return try token(jsonData: message)
    }

    public func decrypt(with key: SymmetricKey<VersionType>) -> Token? {
        return try? decrypt(with: key)
    }
}
