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
        case is Encrypted<Version1>.Type, is Encrypted<Version2>.Type:
            self = .Local

        case is Signed<Version1>.Type, is Signed<Version2>.Type:
            self = .Public
        default: fatalError("All implementations must be enumerated")
        }
    }
}
