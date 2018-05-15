//
//  Version1.swift
//  Paseto
//
//  Created by Aidan Woods on 09/03/2018.
//

import Foundation

public enum Version1 {
    public struct Local {}
}

extension Version1: DeferredLocal {
    public typealias SymmetricKey = Local.SymmetricKey
}
