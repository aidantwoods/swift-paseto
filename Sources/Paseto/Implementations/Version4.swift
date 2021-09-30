import Foundation

public enum Version4 {
    public struct Local {}
    public struct Public {}
}

extension Version4 {
    public enum Exception: Error {
        case invalidSignature(String)
    }
}

extension Version4: DeferredLocal {
    public typealias SymmetricKey = Local.SymmetricKey
}

extension Version4: DeferredPublic {
    public typealias AsymmetricSecretKey = Public.AsymmetricSecretKey
    public typealias AsymmetricPublicKey = Public.AsymmetricPublicKey
}

extension Version4: NonThrowingLocalEncrypt {}
extension Version4: NonThrowingPublicSign {}
