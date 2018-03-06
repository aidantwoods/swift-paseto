//
//  Blob.swift
//  Paseto
//
//  Created by Aidan Woods on 05/03/2018.
//

import Foundation

public struct Blob {
    public let header: Header
    public let payload: Data
    public let footer: Data
    
    var asString: String {
        let main = header.asString + payload.base64UrlNpEncoded
        guard !footer.isEmpty else { return main }
        return main + "." + footer.base64UrlNpEncoded
    }
    var asData: Data { return Data(self.asString.utf8) }
    
    init (header: Header, payload: Data, footer: Data = Data()) {
        self.header  = header
        self.payload = payload
        self.footer  = footer
    }
    
    init? (serialised string: String) {
        let parts = string.split(
            separator: ".", omittingEmptySubsequences: false
        ).map(String.init)
        
        guard parts.count == 3 || parts.count == 4 else {
            return nil
        }
        
        guard
            let header = Header(
                serialised: parts[0...1].joined(separator: ".") + "."
            ),
            let payload = Data(base64UrlNpEncoded: parts[2]) else {
            return nil
        }
        
        guard parts.count > 3 else {
            self.init(header: header, payload: payload)
            return
        }
        
        guard let footer = Data(base64UrlNpEncoded: parts[3]) else {
            return nil
        }
        
        self.init(header: header, payload: payload, footer: footer)
    }
}
