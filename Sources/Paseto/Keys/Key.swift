//
//  Key.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public protocol Key {
    var version: Version { get }
    var material: Data { get }
}
