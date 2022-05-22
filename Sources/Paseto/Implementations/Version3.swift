import Foundation

public enum Version3 {
    public struct Local {}

    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, macCatalyst 13, *)
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

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, macCatalyst 13, *)
extension Version3: DeferredPublic {
    public typealias AsymmetricSecretKey = Public.AsymmetricSecretKey
    public typealias AsymmetricPublicKey = Public.AsymmetricPublicKey
}
