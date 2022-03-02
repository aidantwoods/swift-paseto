import Foundation

public protocol AsymmetricPublicKey: Key where
    Module: BasePublic,
    Module.AsymmetricPublicKey == Self
{}
