//
//  SymmetricKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Sodium
import Foundation

public protocol SymmetricKey: Key where
    ImplementationType: Local,
    ImplementationType.SymmetricKey == Self
{
    init ()
}
