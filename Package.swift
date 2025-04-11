// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JoblogicQRScanner",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "JoblogicQRScanner",
            targets: ["JoblogicQRScanner"]
        ),
    ],
    targets: [
        .target(
            name: "JoblogicQRScanner",
            path: "Sources/Library",
            resources: [
               
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include"),
            ]
        ),
    ]
)

