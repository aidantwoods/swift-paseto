//
//  Token.swift
//  Paseto
//
//  Created by Aidan Woods on 08/03/2018.
//

import Foundation
import TypedJSON

public struct Token {
    public var claims: [String: JSON.Value]
    public var footer: String
    public var allowedVersions: [Version]

    public init (
        claims: [String: JSON.Value] = [:],
        footer: String = "",
        allowedVersions: [Version] = [.v4]
    ) {
        self.claims = claims
        self.footer = footer
        self.allowedVersions = allowedVersions
    }

    public init (
        claims: [String: String] = [:],
        footer: String = "",
        allowedVersions: [Version] = [.v4]
    ) {
        self.claims = claims.mapValues{JSON.Value.String($0)}
        self.footer = footer
        self.allowedVersions = allowedVersions
    }

    public subscript(key: String) -> JSON.Value? {
        get { return claims[key] }
        set (value) { claims[key] = value }
    }

    public init (jsonData: Data, footer: String, allowedVersions: [Version]) throws {
        guard case .Dictionary(let claims) = try JSON.decode(jsonData) else {
            throw Exception.decodeError("Top level of claims must be a dictionary")
        }

        self.claims = claims
        self.footer = footer
        self.allowedVersions = allowedVersions
    }
}

public extension Token {
    func adding(claims newClaims: [String: JSON.Value]) -> Token {
        return Token(
            claims: claims.merging(newClaims) { $1 },
            footer: footer,
            allowedVersions: allowedVersions
        )
    }

    func adding(claims newClaims: [String: String]) -> Token {
        return Token(
            claims: claims.merging(newClaims.mapValues{JSON.Value.String($0)}) { $1 },
            footer: footer,
            allowedVersions: allowedVersions
        )
    }

    func with(footer newFooter: String) -> Token {
        return Token(
            claims: claims,
            footer: newFooter,
            allowedVersions: allowedVersions
        )
    }

    func with(allowedVersions newAllowedVersions: [Version]) -> Token {
        return Token(
            claims: claims,
            footer: footer,
            allowedVersions: newAllowedVersions
        )
    }
}

extension Token {
    var serialisedClaims: Data {
        return JSON.Container.Dictionary(claims).encoded()
    }
}

public extension Token {
    func sign<K: AsymmetricSecretKey>(with key: K) throws -> Message<K.Module> {
        guard allowedVersions.contains(Version(module: K.Module.self)) else {
            throw Exception.disallowedVersion(
                "The version associated with the given key is not allowed."
            )
        }

        return try K.Module.sign(
            serialisedClaims,
            with: key,
            footer: Data(footer.utf8)
        )
    }

    func encrypt<K: SymmetricKey>(with key: K) throws -> Message<K.Module> {
        guard allowedVersions.contains(Version(module: K.Module.self)) else {
            throw Exception.disallowedVersion(
                "The version associated with the given key is not allowed."
            )
        }

        return try K.Module.encrypt(
            serialisedClaims,
            with: key,
            footer: Data(footer.utf8)
        )
    }
}

public extension Token {
    enum Exception: Error {
        case serialiseError(String)
        case decodeError(String)
        case disallowedVersion(String)
    }
}

extension Token: Equatable {
    public static func == (left: Token, right: Token) -> Bool {
        return left.claims == right.claims
            && left.footer == right.footer
            && left.allowedVersions == right.allowedVersions
    }
}
