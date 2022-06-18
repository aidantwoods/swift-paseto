import Foundation

public enum Version3 {
    public struct Local {}

    @available(macOS 11, iOS 14, watchOS 7, tvOS 14, macCatalyst 14, *)
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

@available(macOS 11, iOS 14, watchOS 7, tvOS 14, macCatalyst 14, *)
extension Version3: DeferredPublic {
    public typealias AsymmetricSecretKey = Public.AsymmetricSecretKey
    public typealias AsymmetricPublicKey = Public.AsymmetricPublicKey
}
