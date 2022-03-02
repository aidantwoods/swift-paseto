import Foundation

public struct Parser<M: Module> {
    public typealias Module = M
    public typealias Payload = M.Payload

    public var rules: [Rule]

    public init (rules: [Rule] = [Rules.notExpired()]) {
        self.rules = rules
    }

    public mutating func addRule(_ rule: @escaping Rule) {
        rules.append(rule)
    }
}

public extension Parser where M: BasePublic {
    func verify(_ tainted: String, with key: M.AsymmetricPublicKey) throws -> Token {
        guard let message = Message<Module>(tainted) else {
            throw Exception.badMessage("Could not parse PASETO message.")
        }

        let token = try message.verify(with: key)

        try validate(token)

        return token
    }
}

public extension Parser where M: BaseLocal {
    func decrypt(_ tainted: String, with key: M.SymmetricKey) throws -> Token {
        guard let message = Message<Module>(tainted) else {
            throw Exception.badMessage("Could not parse PASETO message.")
        }

        let token = try message.decrypt(with: key)

        try validate(token)

        return token
    }
}

public extension Parser {
    func validate(_ token: Token) throws {
        _ = try rules.map({
            switch $0(token) {
            case .pass: return
            case .violation(let error): throw error
            }
        })
    }
}

extension Parser {
    enum Exception: Error {
        case badMessage(String)
    }
}
