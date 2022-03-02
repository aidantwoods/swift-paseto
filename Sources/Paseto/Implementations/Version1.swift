import Foundation

public enum Version1 {
    public struct Local {}
}

extension Version1: DeferredLocal {
    public typealias SymmetricKey = Local.SymmetricKey
}
