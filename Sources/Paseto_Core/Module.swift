//
//  Version.swift
//  Paseto_Core
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public protocol Module {
    associatedtype Payload: Paseto_Core.Payload
    static var version: Version { get }
}
