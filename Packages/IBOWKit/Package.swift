// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "IBOWKit",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "WeatherDomain", targets: ["WeatherDomain"]),
        .library(name: "WeatherData", targets: ["WeatherData"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "WeatherPresentation", targets: ["WeatherPresentation"]),
        .library(name: "SearchFeature", targets: ["SearchFeature"]),
        .library(name: "DetailFeature", targets: ["DetailFeature"]),
    ],
    targets: [
        // Pure Swift: entities, ports (protocols), use cases. No framework deps.
        .target(name: "WeatherDomain"),
        // Adapters: HTTP, DTOs, cache. Depends only on Domain.
        .target(name: "WeatherData", dependencies: ["WeatherDomain"]),

        // UI tokens + glass components. UI code defaults to the main actor.
        .target(
            name: "DesignSystem",
            resources: [.process("Resources")],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),

        // Formatting + accessibility strings + shared views for METAR data.
        .target(
            name: "WeatherPresentation",
            dependencies: ["WeatherDomain", "DesignSystem"],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        // Feature: search screen. Knows the Domain, never the Data layer.
        .target(
            name: "SearchFeature",
            dependencies: ["WeatherDomain", "DesignSystem", "WeatherPresentation"],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        // Feature: METAR detail + interactive reader. Independent from SearchFeature.
        .target(
            name: "DetailFeature",
            dependencies: ["WeatherDomain", "DesignSystem", "WeatherPresentation"],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),

        .testTarget(name: "WeatherDomainTests", dependencies: ["WeatherDomain"]),
        .testTarget(name: "WeatherDataTests", dependencies: ["WeatherData", "WeatherDomain"]),
        .testTarget(name: "DesignSystemTests", dependencies: ["DesignSystem"]),
        .testTarget(name: "WeatherPresentationTests", dependencies: ["WeatherPresentation", "WeatherDomain"]),
        .testTarget(name: "SearchFeatureTests", dependencies: ["SearchFeature", "WeatherDomain"]),
    ]
)
