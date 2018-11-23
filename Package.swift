// swift-tools-version:4.0
//
//  Package.swift
//  Paseto
//
//  Created by Aidan Woods on 04/03/2018.
//  Copyright © 2017 Aidan Woods. All rights reserved.
//


import PackageDescription

let package = Package(
    name: "Paseto",
    products: [
        .library(name: "Paseto", targets: ["Paseto"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/jedisct1/swift-sodium.git",
            .upToNextMinor(from: "0.7.0")
        ),
        .package(
            url: "https://github.com/tiwoc/Clibsodium.git",
            .upToNextMajor(from: "1.0.0")
        ),
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            .upToNextMinor(from: "0.9.0")
        )
    ],
    targets: [
        .target(name: "Paseto", dependencies: ["Sodium", "CryptoSwift"]),
        .testTarget(name: "PasetoTests", dependencies: ["Paseto"]),
    ]
)
