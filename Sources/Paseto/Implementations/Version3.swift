import Foundation

public enum Version3 {
    public struct Local {}
    public struct Public {}
}

extension Version3 {
    public enum Exception: Error {
        case invalidSignature(String)
    }
}

extension Version3: DeferredLocal {
    public typealias SymmetricKey = Local.SymmetricKey
}

extension Version3: DeferredPublic {
    public typealias AsymmetricSecretKey = Public.AsymmetricSecretKey
    public typealias AsymmetricPublicKey = Public.AsymmetricPublicKey
}
