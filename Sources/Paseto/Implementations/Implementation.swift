//
//  Version.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public protocol Implementation {
    associatedtype Payload: Paseto.Payload
}

public extension Implementation {
    static var version: Version { return Version(implementation: self) }
}
