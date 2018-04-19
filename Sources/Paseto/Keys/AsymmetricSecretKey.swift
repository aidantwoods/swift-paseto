//
//  AsymmetricSecretKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public protocol AsymmetricSecretKey: Key where
    Module: BasePublic,
    Module.SecretKey == Self
{
    init ()

    var publicKey: Module.PublicKey { get }
}
