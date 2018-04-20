//
//  Purpose.swift
//  Paseto
//
//  Created by Aidan Woods on 05/03/2018.
//

public enum Purpose: String {
    case Local  = "local"
    case Public = "public"
}

extension Purpose {
    init <P: Payload>(payload: P.Type) {
        switch payload {
        case is Version1.Local.Payload.Type: self = .Local
        case is Version2.Local.Payload.Type: self = .Local
        case is Version2.Public.Payload.Type: self = .Public
        default: fatalError("All implementations must be enumerated")
        }
    }
}
