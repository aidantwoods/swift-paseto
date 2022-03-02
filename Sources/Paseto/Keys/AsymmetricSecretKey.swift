import Foundation

public protocol AsymmetricSecretKey: Key where
    Module: BasePublic,
    Module.AsymmetricSecretKey == Self
{
    init ()

    var publicKey: Module.AsymmetricPublicKey { get }
}
