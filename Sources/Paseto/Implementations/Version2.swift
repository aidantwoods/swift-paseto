//
//  Version2.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public enum Version2 {
    public struct Local {}
    public struct Public {}
}

extension Version2 {
    public enum Exception: Error {
        case invalidSignature(String)
    }
}

extension Version2: DeferredLocal {
    public typealias SymmetricKey = Local.SymmetricKey
}

extension Version2: DeferredPublic {
    public typealias AsymmetricSecretKey = Public.AsymmetricSecretKey
    public typealias AsymmetricPublicKey = Public.AsymmetricPublicKey
}

extension Version2: NonThrowingLocalEncrypt {}
extension Version2: NonThrowingPublicSign {}
