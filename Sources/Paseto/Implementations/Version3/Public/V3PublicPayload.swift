import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, macCatalyst 13, *)
extension Version3.Public: Module {
    public struct Payload {
        static let signatureLength = 96

        let message: Bytes
        let signature: Bytes
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, macCatalyst 13, *)
extension Version3.Public.Payload: Paseto.Payload {
    public var bytes: Bytes { return message + signature }

    public init? (bytes: Bytes) {
        let signatureOffset = bytes.count - Version3.Public.Payload.signatureLength

        guard signatureOffset > 0 else { return nil }

        self.init(
            message:   bytes[..<signatureOffset].bytes,
            signature: bytes[signatureOffset...].bytes
        )
    }
}
