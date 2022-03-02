import Foundation

extension Data: PureBytesRepresentable, BytesRepresentable {
    public var bytes: Bytes { return Bytes(self) }

    public init (bytes: Bytes) {
        self.init(bytes)
    }
}
