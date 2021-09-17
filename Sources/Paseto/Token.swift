//
//  Token.swift
//  Paseto
//
//  Created by Aidan Woods on 08/03/2018.
//

import Foundation

infix operator <+: AdditionPrecedence

public struct Token {
    public var claims: [String: String]
    public var footer: String
    public var allowedVersions: [Version]

    public init (
        claims: [String: String] = [:],
        footer: String = "",
        allowedVersions: [Version] = [.v2]
    ) {
        self.claims = claims
        self.footer = footer
        self.allowedVersions = allowedVersions
    }

    public subscript(key: String) -> String? {
        get { return claims[key] }
        set (value) { claims[key] = value }
    }

    public init (
        jsonData: Data, footer: String, allowedVersions: [Version]
    ) throws {
        guard let claims = try JSONSerialization.jsonObject(with: jsonData)
            as? [String: String]
        else {
            throw Exception.decodeError("Could not decode claims")
        }

        self.claims = claims
        self.footer = footer
        self.allowedVersions = allowedVersions
    }
}

public extension Token {
    func add(claims: [String: String]) -> Token {
        return self <+ claims
    }

    func replace(claims: [String: String]) -> Token {
        return Token(
            claims: claims,
            footer: footer,
            allowedVersions: allowedVersions
        )
    }

    func replace(footer: String) -> Token {
        return Token(
            claims: claims,
            footer: footer,
            allowedVersions: allowedVersions
        )
    }

    func replace(allowedVersions: [Version]) -> Token {
        return Token(
            claims: claims,
            footer: footer,
            allowedVersions: allowedVersions
        )
    }
}

public extension Token {
    static func <+ (left: Token, right: [String: String]) -> Token {
        return left.replace(claims: left.claims <+ right)
    }
}

extension Token {
    var serialisedClaims: Data? {
        return try? JSONSerialization.data(withJSONObject: claims)
    }
}

public extension Token {
    func sign<K: AsymmetricSecretKey>(with key: K) throws -> Message<K.Module> {
        guard let claimsData = serialisedClaims else {
            throw Exception.serialiseError(
                "The claims could not be serialised."
            )
        }

        guard allowedVersions.contains(Version(module: K.Module.self)) else {
            throw Exception.disallowedVersion(
                "The version associated with the given key is not allowed."
            )
        }

        return try K.Module.sign(
            claimsData,
            with: key,
            footer: Data(footer.utf8)
        )
    }

    func encrypt<K: SymmetricKey>(with key: K) throws -> Message<K.Module> {
        guard let claimsData = serialisedClaims else {
            throw Exception.serialiseError(
                "The claims could not be serialised."
            )
        }

        guard allowedVersions.contains(Version(module: K.Module.self)) else {
            throw Exception.disallowedVersion(
                "The version associated with the given key is not allowed."
            )
        }

        return try K.Module.encrypt(
            claimsData,
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
