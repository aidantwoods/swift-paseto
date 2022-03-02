import Foundation

extension String: BytesRepresentable {
    public var bytes: Bytes { return Bytes(self.utf8) }

    public init? (bytes: Bytes) {
        self.init(data: Data(bytes: bytes), encoding: .utf8)
    }
}
