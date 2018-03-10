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
    init <I: Payload>(payload: I.Type) {
        switch payload {
        case is Encrypted.Type: self = .Local
        case is Signed.Type   : self = .Public
        default: fatalError("All implementations must be enumerated")
        }
    }
}
