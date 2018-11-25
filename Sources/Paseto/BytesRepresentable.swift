//
//  BytesRepresentable.swift
//  Paseto
//
//  Created by Aidan Woods on 13/05/2018.
//

public protocol BytesRepresentable {
    var bytes: Bytes { get }
    init? (bytes: Bytes)
}

public extension BytesRepresentable {
    init? (bytes representation: BytesRepresentable) {
        self.init(bytes: representation.bytes)
    }
}

extension BytesRepresentable {
    var toBase64: String {
        return sodium.utils.bin2base64(
            self.bytes,
            variant: .URLSAFE_NO_PADDING
        )!
    }
}

public protocol PureBytesRepresentable: BytesRepresentable {
    init (bytes: Bytes)
}

extension PureBytesRepresentable {
    init (bytes representation: BytesRepresentable) {
        self.init(bytes: representation.bytes)
    }
}
