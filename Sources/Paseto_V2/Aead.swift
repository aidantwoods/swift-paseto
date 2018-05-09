//
//  Aead.swift
//  Paseto_V2
//
//  Created by Aidan Woods on 08/03/2018.
//

import Foundation
import Clibsodium

public struct Aead {
    public static let nonceBytes = crypto_aead_xchacha20poly1305_ietf_NPUBBYTES
    public static let keyBytes   = crypto_aead_xchacha20poly1305_ietf_KEYBYTES
    public static let aBytes     = crypto_aead_xchacha20poly1305_ietf_ABYTES

    public static func xchacha20poly1305_ietf_encrypt(
        message: Data,
        additionalData: Data,
        nonce: Data,
        secretKey: Data
    ) -> Data? {
        var cipherText = Data(count: message.count + Int(aBytes))
        var cipherTextLen = Data()

        let result = cipherText.withUnsafeMutableBytes { cipherTextPtr in
            cipherTextLen.withUnsafeMutableBytes { cipherTextLen in
                message.withUnsafeBytes { messagePtr in
                    additionalData.withUnsafeBytes { additionalDataPtr in
                        nonce.withUnsafeBytes { noncePtr in
                            secretKey.withUnsafeBytes { secretKeyPtr in
                                crypto_aead_xchacha20poly1305_ietf_encrypt(
                                    UnsafeMutablePointer<UInt8>(cipherTextPtr),
                                    UnsafeMutablePointer<UInt64>(cipherTextLen),

                                    UnsafePointer<UInt8>(messagePtr),
                                    UInt64(message.count),

                                    UnsafePointer<UInt8>(additionalDataPtr),
                                    UInt64(additionalData.count),

                                    nil, noncePtr, secretKeyPtr
                                )
                            }
                        }
                    }
                }
            }
        }

        guard result == 0 else { return nil }

        return cipherText
    }

    public static func xchacha20poly1305_ietf_decrypt(
        cipherText: Data,
        additionalData: Data,
        nonce: Data,
        secretKey: Data
    ) -> Data? {
        var decrypted = Data(count: cipherText.count - Int(aBytes))
        var decryptedLen = Data()

        let result = decrypted.withUnsafeMutableBytes { decryptedPtr in
            decryptedLen.withUnsafeMutableBytes { decryptedLen in
                cipherText.withUnsafeBytes { cipherTextPtr in
                    additionalData.withUnsafeBytes { additionalDataPtr in
                        nonce.withUnsafeBytes { noncePtr in
                            secretKey.withUnsafeBytes { secretKeyPtr in
                                crypto_aead_xchacha20poly1305_ietf_decrypt(
                                    UnsafeMutablePointer<UInt8>(decryptedPtr),
                                    UnsafeMutablePointer<UInt64>(decryptedLen),

                                    nil,

                                    UnsafePointer<UInt8>(cipherTextPtr),
                                    UInt64(cipherText.count),

                                    UnsafePointer<UInt8>(additionalDataPtr),
                                    UInt64(additionalData.count),

                                    noncePtr, secretKeyPtr
                                )
                            }
                        }
                    }
                }
            }
        }

        guard result == 0 else { return nil }

        return decrypted
    }
}
