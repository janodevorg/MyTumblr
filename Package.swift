// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "MyTumblr",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "MyTumblr", type: .static, targets: ["MyTumblr"]),
        .library(name: "MyTumblrStatic", type: .dynamic, targets: ["MyTumblr"])
    ],
    dependencies: [
        .package(url: "git@github.com:janodevorg/APIClient.git", from: "1.0.0"),
        .package(url: "git@github.com:janodevorg/AutoLayout.git", from: "1.0.0"),
        .package(url: "git@github.com:janodevorg/CodableHelpers.git", from: "1.0.0"),
        .package(url: "git@github.com:janodevorg/Coordinator.git", from: "1.0.0"),
        .package(url: "git@github.com:janodevorg/CoreDataStack.git", from: "1.0.0"),
        .package(url: "git@github.com:janodevorg/Dependency.git", from: "1.0.0"),
        .package(url: "git@github.com:janodevorg/ImageCache.git", from: "1.0.0"),
        .package(url: "git@github.com:janodevorg/Keychain.git", from: "1.0.0"),
        .package(url: "git@github.com:janodevorg/Kit.git", from: "1.0.0"),
        .package(url: "git@github.com:janodevorg/OAuth2.git", from: "1.0.0"),
        .package(url: "git@github.com:janodevorg/Report.git", from: "1.0.0"),
        .package(url: "git@github.com:janodevorg/TumblrNPF.git", from: "1.0.0"),
        // .package(path: "../TumblrNPF"),
        .package(url: "git@github.com:janodevorg/TumblrNPFPersistence.git", from: "1.0.0"),
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
                .product(name: "CoreDataStackDynamic", package: "CoreDataStack"),
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
