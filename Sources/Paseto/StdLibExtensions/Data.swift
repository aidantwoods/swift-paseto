//
//  Data.swift
//  Paseto
//
//  Created by Aidan Woods on 05/03/2018.
//

import Sodium
import Foundation

extension BytesRepresentable {
    var base64UrlNoPad: String {
        return Sodium().utils.bin2base64(
            self.bytes,
            variant: .URLSAFE_NO_PADDING
        )!
    }

    init? (base64UrlNoPad encoded: String) {
        guard let decoded = Sodium().utils.base642bin(
            encoded,
            variant: .URLSAFE_NO_PADDING
        ) else { return nil }

        self.init(bytes: decoded)
    }
}
