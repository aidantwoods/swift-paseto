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
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(name: "Paseto", targets: ["Paseto"]),
    ],
    dependencies: [
        .package(
            name: "Sodium",
            url: "https://github.com/aidantwoods/swift-sodium.git",
            .branch("full-clibsodium-build")
        ),
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            .upToNextMajor(from: "1.4.2")
        ),
        .package(
            url: "https://github.com/aidantwoods/TypedJSON.git",
            .upToNextMinor(from: "0.1.2")
        )
    ],
    targets: [
        .target(
            name: "Paseto",
            dependencies: [
                .product(name: "Clibsodium", package: "Sodium"),
                .product(name: "Sodium", package: "Sodium"),
                "CryptoSwift",
                "TypedJSON"
            ]
        ),
        .testTarget(
            name: "PasetoTests",
            dependencies: ["Paseto"],
            resources: [
                .copy("TestVectors")
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
