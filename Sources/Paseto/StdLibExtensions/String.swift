//
//  String.swift
//  Paseto
//
//  Created by Aidan Woods on 30/03/2018.
//

extension String {
    func split(with separator: Character) -> [String] {
        return self.split(
            separator: separator, omittingEmptySubsequences: false
        ).map(String.init)
    }
}
