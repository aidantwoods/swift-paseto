//
//  Version1.swift
//  Paseto
//
//  Created by Aidan Woods on 09/03/2018.
//

import Foundation

public enum Version1 {
    public struct Local {
        static let keyBytes   = 32
        static let nonceBytes = 32
        static let macBytes   = 48
    }
}

extension Version1: DeferredLocal {
    public typealias SymmetricKey = Local.SymmetricKey
}
