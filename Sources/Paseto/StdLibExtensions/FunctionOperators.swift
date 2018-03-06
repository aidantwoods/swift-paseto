//
//  FunctionOperators.swift
//
//  Created by Aidan Woods on 19/02/2018.
//

precedencegroup CompositionPrecedence {
    higherThan: ApplicationPrecedence
    associativity: right
}

precedencegroup ApplicationPrecedence {
    higherThan: MultiplicationPrecedence
    associativity: right
}

infix operator •: CompositionPrecedence
infix operator ^•: ApplicationPrecedence

func • <A,B,C>(lhs: @escaping (B) -> C, rhs: @escaping (A) -> B) -> (A) -> C {
    return { lhs(rhs($0)) }
}

func ^• <A, B, C>(lhs: (A) -> B, rhs: C) -> [B] where
    C: Collection, C.Element == A
{
    return rhs.map(lhs)
}

func ^• <A, B, C, D>(lhs: (A) -> B, rhs: C) -> D where
    C: Collection, C: SetAlgebra, D: SetAlgebra,
    C.Element == A, D.Element == B
{
    return D(rhs.map(lhs))
}

prefix func !<D>(fn: @escaping (D) -> Bool) -> (D) -> Bool {
    return (!) • fn
}

