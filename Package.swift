//
//  Package.swift
//  StringEx
//
//  Created by Andrey Golovchak on 04.04.2022.
//  Copyright © 2022 Andrew Golovchak. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "StringEx",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_11),
        .tvOS(.v10),
    ],
    products: [
        .library(name: "StringEx", targets: ["StringEx"]),
        .library(name: "StringEx-Dynamic", type: .dynamic, targets: ["StringEx"]),
    ],
    targets: [
        .target(name: "StringEx", path: "Sources"),
        .testTarget(name: "StringExTests", dependencies: ["StringEx"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
