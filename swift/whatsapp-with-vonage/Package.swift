// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "whatsapp-with-vonage",
    platforms: [.macOS(.v11), .iOS(.v13), .tvOS(.v11), .watchOS(.v4)],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/Kitura/Swift-JWT.git", from: "3.0.0"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "0.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "whatsapp-with-vonage",
            dependencies: [.product(name: "Vapor", package: "vapor"),
                           .product(name: "HTTPTypes", package: "swift-http-types"),
                           .product(name: "SwiftJWT", package: "Swift-JWT")
            ]
        )
    ]
)
