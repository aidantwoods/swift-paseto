import Foundation
import Clibsodium

public struct Aead {
    public static let nonceBytes = Int(crypto_aead_xchacha20poly1305_ietf_NPUBBYTES)
    public static let keyBytes   = Int(crypto_aead_xchacha20poly1305_ietf_KEYBYTES)
    public static let aBytes     = Int(crypto_aead_xchacha20poly1305_ietf_ABYTES)

    public static func xchacha20poly1305_ietf_encrypt(
        message: Bytes,
        additionalData: Bytes,
        nonce: Bytes,
        secretKey: Bytes
    ) -> Bytes? {
        guard secretKey.count == keyBytes else { return nil }

        var authenticatedCipherText = Bytes(count: message.count + aBytes)
        var authenticatedCipherTextLen: UInt64 = 0

        guard 0 == crypto_aead_xchacha20poly1305_ietf_encrypt(
            &authenticatedCipherText, &authenticatedCipherTextLen,
            message, UInt64(message.count),
            additionalData, UInt64(additionalData.count),
            nil, nonce, secretKey
        ) else { return nil }

        return authenticatedCipherText
    }

    public static func xchacha20poly1305_ietf_decrypt(
        authenticatedCipherText: Bytes,
        additionalData: Bytes,
        nonce: Bytes,
        secretKey: Bytes
    ) -> Bytes? {
        guard authenticatedCipherText.count >= aBytes else { return nil }

        var message = Bytes(count: authenticatedCipherText.count - aBytes)
        var messageLen: UInt64 = 0

        guard 0 == crypto_aead_xchacha20poly1305_ietf_decrypt(
            &message, &messageLen,
            nil,
            authenticatedCipherText, UInt64(authenticatedCipherText.count),
            additionalData, UInt64(additionalData.count),
            nonce, secretKey
        ) else { return nil }

        return message
    }
}
