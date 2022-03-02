import Foundation

public enum RuleResult {
    case pass
    case violation(Error)
}

public typealias Rule = (Token) -> RuleResult

public enum Rules {

}

public extension Rules {
    static func forAudience(_ audience: String) -> Rule {
        return { token in
            guard let aud = token.audience else {
                return .violation(Exception.badAud("The claim `aud' was not present."))
            }

            guard Util.equals(aud.bytes, audience.bytes) else {
                return .violation(Exception.badAud(
                    "Expected aud claim to be `" + audience + "', `" + aud + "' given."
                ))
            }

            return .pass
        }
    }

    static func identifiedBy(_ identifier: String) -> Rule {
        return { token in
            guard let jti = token.jti else {
                return .violation(Exception.badJti("The claim `jti' was not present."))
            }

            guard Util.equals(jti.bytes, identifier.bytes) else {
                return .violation(Exception.badJti(
                    "Expected jti claim to be `" + identifier + "', `" + jti + "' given."
                ))
            }

            return .pass
        }
    }

    static func issuedBy(_ issuer: String) -> Rule {
        return { token in
            guard let iss = token.issuer else {
                return .violation(Exception.badIss("The claim `iss' was not present."))
            }

            guard Util.equals(iss.bytes, issuer.bytes) else {
                return .violation(Exception.badIss(
                    "Expected iss claim to be `" + issuer + "', `" + iss + "' given."
                ))
            }

            return .pass
        }
    }

    static func notExpired() -> Rule {
        return { token in
            guard let exp = token.expiration else {
                return .violation(Exception.badExp("The claim `exp' was not present."))
            }

            guard Date() < exp else {
                return .violation(Exception.badExp(
                    "This token has expired."
                ))
            }

            return .pass
        }
    }

    static func subject(_ subject: String) -> Rule {
        return { token in
            guard let sub = token.subject else {
                return .violation(Exception.badSub("The claim `iss' was not present."))
            }

            guard Util.equals(sub.bytes, subject.bytes) else {
                return .violation(Exception.badSub(
                    "Expected sub claim to be `" + subject + "', `" + sub + "' given."
                ))
            }

            return .pass
        }
    }

    static func validAt(_ time: Date) -> Rule {
        return { token in
            guard let iat = token.issuedAt else {
                return .violation(Exception.badIat(
                    "The claim `iat' was not present."
                ))
            }
            guard time >= iat else {
                return .violation(Exception.badIat(
                    "The valid at time is before this token was issued."
                ))
            }

            guard let nbf = token.notBefore else {
                return .violation(Exception.badNbf(
                    "The claim `nbf' was not present."
                ))
            }
            guard time >= nbf else {
                return .violation(Exception.badIat(
                    "The valid at time is before this token's not before time."
                ))
            }

            guard let exp = token.expiration else {
                return .violation(Exception.badExp(
                    "The claim `exp' was not present."
                ))
            }
            guard Date() < exp else {
                return .violation(Exception.badExp(
                    "The valid at time is after this token expires."
                ))
            }

            return .pass
        }
    }
}


public extension Rules {
    enum Exception: Error {
        case badAud(String)
        case badJti(String)
        case badIss(String)
        case badExp(String)
        case badSub(String)
        case badIat(String)
        case badNbf(String)
    }
}


public extension Token {
    func getString(key: String) -> String? {
        guard case .String(let val) = self[key] else {
            return nil
        }

        return val
    }

    mutating func setString(key: String, _ val: String?) {
        switch val {
        case .none: self[key] = nil
        case .some(let val): self[key] = .String(val)
        }
    }

    func getDate(key: String) -> Date? {
        guard case .String(let val) = self[key] else {
            return nil
        }

        return timeFormatter.date(from: val)
    }

    mutating func setDate(key: String, _ val: Date?) {
        switch val {
        case .none: self[key] = nil
        case .some(let date): self[key] = .String(timeFormatter.string(from: date))
        }
    }

    var audience: String? {
        get { getString(key: "aud") }
        set { setString(key: "aud", newValue) }
    }

    var expiration: Date? {
        get { getDate(key: "exp") }
        set { setDate(key: "exp", newValue) }
    }

    var issuedAt: Date? {
        get { getDate(key: "iat") }
        set { setDate(key: "iat", newValue) }
    }

    var issuer: String? {
        get { getString(key: "iss") }
        set { setString(key: "iss", newValue) }
    }

    var jti: String? {
        get { getString(key: "jti") }
        set { setString(key: "jti", newValue) }
    }

    var notBefore: Date? {
        get { getDate(key: "nbf") }
        set { setDate(key: "nbf", newValue) }
    }

    var subject: String? {
        get { getString(key: "sub") }
        set { setString(key: "sub", newValue) }
    }
}
