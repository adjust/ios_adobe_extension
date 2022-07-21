// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdjustAdobeExtension",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "AdjustAdobeExtension",
            targets: ["AdjustAdobeExtension"])
    ],
    dependencies: [
        .package(
            name: "Adjust",
            url: "https://github.com/adjust/ios_sdk.git",
            from: "4.31.0"
        ),
    ],
    targets: [
        .target(
            name: "AdjustAdobeExtension",
            dependencies: ["Adjust","ACPCore","ACPIdentity","ACPLifecycle","ACPSignal"],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include/AdjustAdobeExtension")
            ]
        ),
        .binaryTarget(
            name: "ACPCore",
            url: "https://github.com/adjust/ios_adobe_extension/releases/download/v1.0.4/ACPCore.xcframework-2.9.5.zip",
            checksum: "1feb78e211bfc1d4e52e499323772f66c3eaab56434342465f7ee8a036a51fa9"
        ),
        .binaryTarget(
            name: "ACPIdentity",
            url: "https://github.com/adjust/ios_adobe_extension/releases/download/v1.0.4/ACPIdentity.xcframework-2.5.2.zip",
            checksum: "9a4843568ad0832e575dbecb2524265bbfd9baf2557bc972f78b4359d70f8bc0"
        ),
        .binaryTarget(
            name: "ACPLifecycle",
            url: "https://github.com/adjust/ios_adobe_extension/releases/download/v1.0.4/ACPLifecycle.xcframework-2.2.1.zip",
            checksum: "02d7b6a1c615d9f5b222d58a95a0ded1ce4b1dac60fbecc9858d9e8dcd74c2eb"
        ),
        .binaryTarget(
            name: "ACPSignal",
            url: "https://github.com/adjust/ios_adobe_extension/releases/download/v1.0.4/ACPSignal.xcframework-2.2.0.zip",
            checksum: "2f7c9db8e8163fe2c5aa3e89fce485075b32751e65402f10a69eea674dd965a5"
        )
    ]
)
