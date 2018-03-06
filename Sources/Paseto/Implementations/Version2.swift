//
//  Version2.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//

import Foundation

public struct Version2: Implementation {
    static let signBytes: Int = Sign.Bytes
    public static var version: Version { return .v2 }
    public static func sign(
        _ data: Data, with key: AsymmetricSecretKey, footer: Data
    ) -> Blob {
        let header = Header(version: version, purpose: .Public)

        let signature = Sign.signature(
            message: Util.pae([header.asData, data, footer]),
            secretKey: key.material
        )!
        
        return Blob(header: header, payload: data + signature, footer: footer)
    }

    public static func verify(
        _ signedMessage: Blob, with key: AsymmetricPublicKey, footer: Data
    ) throws -> Data {
        let header = signedMessage.header
        guard header == Header(version: version, purpose: .Public) else {
            throw Exception.badHeader("Bad message header.")
        }
        guard footer == signedMessage.footer else {
            throw Exception.badFooter("Invalid message footer.")
        }
        
        let payload   = signedMessage.payload
        let message   = payload[..<(payload.count - signBytes)]
        let signature = payload[(payload.count - signBytes)...]
        
        let isValid = Sign.verify(
            message: Util.pae([header.asData, message, footer]),
            publicKey: key.material,
            signature: signature
        )
        
        guard isValid else {
            throw Exception.invalidSignature(
                "Invalid signature for this message."
            )
        }
        
        return message
    }
    
    public enum Exception: Error {
        case badHeader(String)
        case badFooter(String)
        case invalidSignature(String)
    }
}
