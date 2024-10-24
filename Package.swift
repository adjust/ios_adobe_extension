// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdjustAdobeExtension",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "AdjustAdobeExtension",
            targets: ["AdjustAdobeExtension"])
    ],
    dependencies: [
        .package(url: "https://github.com/adjust/ios_sdk.git", exact: "5.0.1"),
        .package(url: "https://github.com/adobe/aepsdk-core-ios.git", from: "4.2.0")],
    targets: [
        .target(
            name: "AdjustAdobeExtension",
            dependencies: [
                .product(name: "AEPCore", package: "aepsdk-core-ios"),
                .product(name: "AdjustSdk", package: "ios_sdk")],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include/AdjustAdobeExtension")
            ]
        )
    ]
)
