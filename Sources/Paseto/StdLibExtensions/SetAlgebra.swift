//
//  SetAlgebra.swift
//  Paseto
//
//  Created by Aidan Woods on 05/03/2018.
//

extension SetAlgebra {
    static func + (left: Self, right: Self) -> Self {
        return left.union(right)
    }
}
