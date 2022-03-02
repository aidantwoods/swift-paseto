import Clibsodium

struct XChaCha20 {
    static let keyBytes = Int(crypto_stream_xchacha20_KEYBYTES)
    static let nonceBytes = Int(crypto_stream_xchacha20_NONCEBYTES)

    static func crypto_stream_xor(
        message: Bytes,
        nonce: Bytes,
        secretKey: Bytes
    ) -> Bytes? {
        guard secretKey.count == keyBytes, nonce.count == nonceBytes else {
            return nil
        }

        var cipherText = Bytes(count: message.count)

        guard 0 == crypto_stream_xchacha20_xor(
            &cipherText,
            message, UInt64(message.count),
            nonce, secretKey
        ) else { return nil }

        return cipherText
    }
}
