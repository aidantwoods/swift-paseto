//
//  AsymmetricPublicKey.swift
//  Paseto_Core
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public protocol AsymmetricPublicKey: Key where
    Module: BasePublic,
    Module.AsymmetricPublicKey == Self
{}
