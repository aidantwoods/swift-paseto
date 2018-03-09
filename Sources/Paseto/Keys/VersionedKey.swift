//
//  VersionedKey.swift
//  Paseto
//
//  Created by Aidan Woods on 09/03/2018.
//

import Foundation

protocol VersionedKey: Key {
    associatedtype VersionType: Implementation
}

extension VersionedKey {
    public static var version: Version { return VersionType.version }
}
