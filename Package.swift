// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SFTransitKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "SFTransitKit",
            targets: ["SFTransitKit"]
        ),
    ],
    targets: [
        .target(
            name: "SFTransitKit"
        ),
        .testTarget(
            name: "SFTransitKitTests",
            dependencies: ["SFTransitKit"],
            resources: [
                .process("fixtures/lines.json"),
                .process("fixtures/operators.json"),
                .process("fixtures/stop-monitoring.json"),
                .process("fixtures/stops.json")
            ]
        ),
    ]
)
