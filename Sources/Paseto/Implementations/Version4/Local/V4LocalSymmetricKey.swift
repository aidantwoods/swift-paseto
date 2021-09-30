import Foundation

public extension Version4.Local {
    struct SymmetricKey: Paseto.SymmetricKey {
        public static let length = 32

        public let material: Bytes
        public typealias Module = Version4.Local

        public init (material: Bytes) {
            self.material = material
        }

        public init () {
            self.init(bytes: Util.random(length: Module.SymmetricKey.length))!
        }
    }
}

extension Version4.Local.SymmetricKey {
    func split(nonce: BytesRepresentable) throws -> (Ek: Bytes, Ak: Bytes, n2: Bytes) {
        let nonceBytes = nonce.bytes
        guard nonceBytes.count == Module.Payload.nonceLength else {
            throw Exception.badNonce(
                "Nonce must be exactly "
                + String(Module.Payload.nonceLength)
                + " bytes"
            )
        }

        let tmp = sodium.genericHash.hash(
            message: "paseto-encryption-key".bytes + nonceBytes,
            key: material,
            outputLength: 56
        )!

        let encKey = tmp[0..<32].bytes
        let nonce2 = tmp[32..<56].bytes
        
        let authKey = sodium.genericHash.hash(
            message: "paseto-auth-key-for-aead".bytes + nonceBytes,
            key: material,
            outputLength: 32
        )!

        return (Ek: encKey, Ak: authKey, n2: nonce2)
    }
}

extension Version4.Local.SymmetricKey {
    enum Exception: Error {
        case badNonce(String)
    }
}
