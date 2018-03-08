//
//  Version.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

public enum Version: String {
    case v2 = "v2"
}

extension Version {
    init <I: Implementation>(implementation: I.Type) {
        switch implementation {
        case is Version2.Type: self = .v2
        default: fatalError("All implementations must be enumerated")
        }
    }
}
