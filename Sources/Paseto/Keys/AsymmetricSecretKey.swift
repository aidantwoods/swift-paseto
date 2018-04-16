//
//  AsymmetricSecretKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public protocol AsymmetricSecretKey: Key where
    ImplementationType: Public,
    ImplementationType.AsymmetricSecretKey == Self
{
    init ()

    var publicKey: ImplementationType.AsymmetricPublicKey { get }
}
