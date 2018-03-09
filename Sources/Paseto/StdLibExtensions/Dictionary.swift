//
//  Dictionary.swift
//  Paseto
//
//  Created by Aidan Woods on 08/03/2018.
//

func <+ <Key, Value> (
    left: Dictionary<Key, Value>, right: Dictionary<Key, Value>
) -> Dictionary<Key, Value> {
    return right.reduce(into: left) { $0[$1.0] = $1.1 }
}
