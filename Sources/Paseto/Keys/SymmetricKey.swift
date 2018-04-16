//
//  SymmetricKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Sodium
import Foundation

public protocol SymmetricKey: Key where
    Implementation: BaseLocal,
    Implementation.SymmetricKey == Self
{
    init ()
}
