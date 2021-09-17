// swift-tools-version:5.3
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
    platforms: [
        // Same baseline as CryptoSwift
        .macOS(.v10_12), .iOS(.v9), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(name: "Paseto", targets: ["Paseto"]),
    ],
    dependencies: [
        .package(
            name: "Sodium",
            url: "https://github.com/jedisct1/swift-sodium.git",
            .upToNextMinor(from: "0.9.1")
        ),
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            .upToNextMajor(from: "1.4.1")
        )
    ],
    targets: [
        .target(name: "Paseto", dependencies: ["Sodium", "CryptoSwift"]),
        .testTarget(name: "PasetoTests", dependencies: ["Paseto"]),
    ],
    swiftLanguageVersions: [.v5]
)
