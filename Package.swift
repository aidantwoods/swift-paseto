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
        .library(name: "Paseto_Core", targets: ["Paseto_Core"]),
        .library(name: "Paseto_V1", targets: ["Paseto_V1"]),
        .library(name: "Paseto_V2", targets: ["Paseto_V2"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/jedisct1/swift-sodium.git",
            .revision("dc62e765f5110a1bfb16a692e18180ba1ee9ae9f")
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
        .target(name: "Paseto", dependencies: ["Paseto_V1", "Paseto_V2"]),
        .target(name: "Paseto_V1", dependencies: ["Paseto_Core", "CryptoSwift", "Sodium"]),
        .target(name: "Paseto_V2", dependencies: ["Paseto_Core", "Sodium"]),
        .target(name: "Paseto_Core", dependencies: ["Sodium"]), 
        .testTarget(name: "PasetoTests", dependencies: ["Paseto"]),
    ]
)
