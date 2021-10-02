import Foundation

public struct Package {
    public let content: Bytes
    public let footer: Bytes

    public init (
        _ content: BytesRepresentable,
        footer: BytesRepresentable = Bytes()
    ) {
        self.content = content.bytes
        self.footer = footer.bytes
    }

    public var string: String? { return String(bytes: self.content) }
    public var footerString: String? { return String(bytes: self.footer) }
}
