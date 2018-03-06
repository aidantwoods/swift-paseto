//
//  Data.swift
//  Paseto
//
//  Created by Aidan Woods on 05/03/2018.
//

import Sodium
import Foundation

extension Data {
    var base64UrlNpEncoded: String {
        return Sodium().utils.bin2base64(self, variant: .URLSAFE_NO_PADDING)!
    }
    
    init?(base64UrlNpEncoded encoded: String) {
        guard let data = Sodium().utils
            .base642bin(encoded, variant: .URLSAFE_NO_PADDING) else {
                return nil
        }
        
        self = data
    }
}
