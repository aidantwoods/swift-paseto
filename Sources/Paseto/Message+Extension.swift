//
//  Message+Extension.swift
//  Paseto
//
//  Created by Aidan Woods on 21/04/2018.
//

@testable import Paseto_Core

extension Message {
    func token(package: Package) throws -> Token {
        guard let footer = package.footer.utf8String else {
            throw Exception.badEncoding(
                "Could not convert the footer to a UTF-8 string."
            )
        }

        return try Token(
            jsonData: package.content,
            footer: footer,
            allowedVersions: [header.version]
        )
    }
}

extension Message where M: BasePublic {
    public func verify(with key: M.AsymmetricPublicKey) throws -> Token {
        let package = try M.verify(self, with: key)
        return try token(package: package)
    }
}

extension Message where M: BaseLocal {
    public func decrypt(with key: M.SymmetricKey) throws -> Token {
        let package = try M.decrypt(self, with: key)
        return try token(package: package)
    }
}
