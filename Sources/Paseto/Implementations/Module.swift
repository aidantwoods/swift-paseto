import Foundation

public protocol Module {
    associatedtype Payload: Paseto.Payload
}

public extension Module {
    static var version: Version { return Version(module: self) }
}
