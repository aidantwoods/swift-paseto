//
//  Version.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public protocol Module {
    associatedtype Payload: Paseto.Payload
}

public extension Module {
    static var version: Version { return Version(module: self) }
}
