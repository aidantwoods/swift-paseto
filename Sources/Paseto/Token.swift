import Foundation
import TypedJSON

public struct Token {
    public var claims: [String: JSON.Value]
    public var footer: String
    internal var timeFormatter = ISO8601DateFormatter()

    public init () {
        self.claims = [:]
        self.footer = ""
    }

    public init (claims: [String: JSON.Value] = [:], footer: String = "") {
        self.claims = claims
        self.footer = footer
    }

    public init (claims: [String: String] = [:], footer: String = "") {
        self.claims = claims.mapValues{JSON.Value.String($0)}
        self.footer = footer
    }

    public subscript(key: String) -> JSON.Value? {
        get { return claims[key] }
        set (value) { claims[key] = value }
    }

    public init (jsonData: Data, footer: String) throws {
        guard case .Dictionary(let claims) = try JSON.decode(jsonData) else {
            throw Exception.decodeError("Top level of claims must be a dictionary")
        }

        self.claims = claims
        self.footer = footer
    }
}

public extension Token {
    func adding(claims newClaims: [String: JSON.Value]) -> Token {
        return Token(
            claims: claims.merging(newClaims) { $1 },
            footer: footer
        )
    }

    func adding(claims newClaims: [String: String]) -> Token {
        return Token(
            claims: claims.merging(newClaims.mapValues{JSON.Value.String($0)}) { $1 },
            footer: footer
        )
    }

    func with(footer newFooter: String) -> Token {
        return Token(
            claims: claims,
            footer: newFooter
        )
    }
}

public extension Token {
    var claimsJSON: Data {
        if #available(macOS 10.13, *) {
            return JSON.Container.Dictionary(claims).encoded(options: [.sortedKeys])
        } else {
            return JSON.Container.Dictionary(claims).encoded()
        }
    }
}

public extension Token {
    func sign<K: AsymmetricSecretKey>(with key: K) throws -> String {
        return try K.Module.sign(
            claimsJSON,
            with: key,
            footer: Data(footer.utf8)
        ).asString
    }

    func encrypt<K: SymmetricKey>(with key: K) throws -> String {
        return try K.Module.encrypt(
            claimsJSON,
            with: key,
            footer: Data(footer.utf8)
        ).asString
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
    }
}
