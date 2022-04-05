// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "MyTumblr",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "MyTumblr", type: .dynamic, targets: ["MyTumblr"]),
        .library(name: "MyTumblrStatic", type: .static, targets: ["MyTumblr"])
    ],
    dependencies: [
        .package(url: "git@github.com:janodevorg/APIClient.git", branch: "main"),
        .package(url: "git@github.com:janodevorg/AutoLayout.git", branch: "main"),
        .package(url: "git@github.com:janodevorg/CodableHelpers.git", branch: "main"),
        .package(url: "git@github.com:janodevorg/Coordinator.git", branch: "main"),
        .package(url: "git@github.com:janodevorg/CoreDataStack.git", branch: "main"),
        .package(url: "git@github.com:janodevorg/Dependency.git", branch: "main"),
        .package(url: "git@github.com:janodevorg/ImageCache.git", branch: "main"),
        .package(url: "git@github.com:janodevorg/Keychain.git", branch: "main"),
        .package(url: "git@github.com:janodevorg/Kit.git", branch: "main"),
        .package(url: "git@github.com:janodevorg/OAuth2.git", branch: "main"),
        .package(url: "git@github.com:janodevorg/Report.git", branch: "main"),
        .package(url: "git@github.com:janodevorg/TumblrNPF.git", branch: "main"),
        // .package(path: "../TumblrNPF"),
        .package(url: "git@github.com:janodevorg/TumblrNPFPersistence.git", branch: "main"),
        .package(url: "git@github.com:apple/swift-docc-plugin.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MyTumblr",
            dependencies: [
                .product(name: "APIClient", package: "APIClient"),
                .product(name: "AutoLayout", package: "AutoLayout"),
                .product(name: "CodableHelpers", package: "CodableHelpers"),
                .product(name: "Coordinator", package: "Coordinator"),
                .product(name: "CoreDataStack", package: "CoreDataStack"),
                .product(name: "Dependency", package: "Dependency"),
                .product(name: "ImageCache", package: "ImageCache"),
                .product(name: "Keychain", package: "Keychain"),
                .product(name: "Kit", package: "Kit"),
                .product(name: "OAuth2", package: "OAuth2"),
                .product(name: "Report", package: "Report"),
                .product(name: "TumblrNPF", package: "TumblrNPF"),
                .product(name: "TumblrNPFPersistence", package: "TumblrNPFPersistence")
            ],
            path: "sources/main",
            exclude: [
                "resource_bundle_accessor.swift"
            ],
            resources: [
                .copy("resources/fonts/Gibson-bold.ttf"),
                .copy("resources/fonts/Gibson-bolditalic.ttf"),
                .copy("resources/fonts/Gibson-regular.ttf"),
                .copy("resources/fonts/Gibson-regularitalic.ttf"),
                .copy("resources/fonts/RugeBoogie-Regular.ttf"),
                .process("resources/hardcoded-posts")
            ]
        ),
        .testTarget(
            name: "MyTumblrTests",
            dependencies: [
                "MyTumblr",
                .product(name: "CodableHelpers", package: "CodableHelpers")
            ],
            path: "sources/tests",
            resources: [
                .process("resources")
            ]
        )
    ]
)
