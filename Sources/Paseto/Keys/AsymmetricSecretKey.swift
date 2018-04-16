//
//  AsymmetricSecretKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public protocol AsymmetricSecretKey: Key where
    Implementation: Public,
    Implementation.AsymmetricSecretKey == Self
{
    init ()

    var publicKey: Implementation.AsymmetricPublicKey { get }
}
