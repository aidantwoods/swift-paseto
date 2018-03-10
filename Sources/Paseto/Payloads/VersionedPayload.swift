//
//  VersionedPayload.swift
//  Paseto
//
//  Created by Aidan Woods on 10/03/2018.
//

public protocol VersionedPayload: Payload {
    associatedtype VersionType: Implementation
}

extension VersionedPayload {
    public static var version: Version { return VersionType.version }
}
