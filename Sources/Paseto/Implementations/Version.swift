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
    var implementation: Implementation.Type {
        switch self {
        case .v2: return Version2.self
        }
    }
}
