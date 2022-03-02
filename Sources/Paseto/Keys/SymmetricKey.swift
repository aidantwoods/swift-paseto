import Sodium
import Foundation

public protocol SymmetricKey: Key where
    Module: BaseLocal,
    Module.SymmetricKey == Self
{
    init ()
}
