import Foundation
import CryptoSwift

extension Version3.Local {
    public struct SymmetricKey {
        public static let length = 32
        public let material: Bytes

        public init (material: Bytes) {
            self.material = material
        }

        public init () {
            self.init(bytes: Util.random(length: Module.SymmetricKey.length))!
        }

    }
}

extension Version3.Local.SymmetricKey: Paseto.SymmetricKey {
    public typealias Module = Version3.Local
}

extension Version3.Local.SymmetricKey {
    func split(nonce: BytesRepresentable) throws -> (Ek: Bytes, Ak: Bytes, n2: Bytes) {
        let nonceBytes = nonce.bytes
        guard nonceBytes.count == Version3.Local.Payload.nonceLength else {
            throw Exception.badNonce(
                "Nonce must be exactly "
                + String(Version3.Local.Payload.nonceLength)
                + " bytes"
            )
        }

        let tmp = try HKDF(
            password: material,
            salt: nil,
            info: "paseto-encryption-key".bytes + nonceBytes,
            keyLength: 48,
            variant: .sha384
        ).calculate()
        
        let encKey = tmp[0..<32].bytes
        let nonce2 = tmp[32..<48].bytes

        let authKey = try HKDF(
            password: material,
            salt: nil,
            info: "paseto-auth-key-for-aead".bytes + nonceBytes,
            keyLength: 48,
            variant: .sha384
        ).calculate()

        return (Ek: encKey, Ak: authKey, n2: nonce2)
    }
}

extension Version3.Local.SymmetricKey {
    enum Exception: Error {
        case badNonce(String)
    }
}
