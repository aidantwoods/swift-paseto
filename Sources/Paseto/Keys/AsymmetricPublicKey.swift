//
//  AsymmetricPublicKey.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public protocol AsymmetricPublicKey: Key where
    Implementation: Public,
    Implementation.AsymmetricPublicKey == Self
{}
