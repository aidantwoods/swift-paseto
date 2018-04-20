//
//  AsymmetricSecretKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public protocol AsymmetricSecretKey: Key where
    Module: BasePublic,
    Module.AsymmetricSecretKey == Self
{
    init ()

    var publicKey: Module.AsymmetricPublicKey { get }
}
