import Foundation

public enum Version3 {
    public struct Local {}
}

extension Version3: DeferredLocal {
    public typealias SymmetricKey = Local.SymmetricKey
}
