//
//  Package.swift
//  Paseto_Core
//
//  Created by Aidan Woods on 18/04/2018.
//

import Foundation

public struct Package {
    public let content: Data
    public let footer: Data

    public init (_ content: Data, footer: Data = Data()) {
        self.content = content
        self.footer = footer
    }

    public var string: String? { return content.utf8String }
    public var footerString: String? { return footer.utf8String }
}
