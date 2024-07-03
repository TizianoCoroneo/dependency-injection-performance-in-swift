// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "dependency-injection-performance",
    platforms: [
        .macOS(.v14),
        .iOS("999")
    ],
    products: [
        .executable(name: "ProjectGeneratorCommands", targets: ["ProjectGeneratorCommands"]),
        .executable(name: "ProfilerTarget", targets: ["ProfilerTarget"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/davecom/SwiftGraph", from: "3.1.0"),
        .package(url: "https://github.com/lemire/SwiftWyhash", from: "0.1.1"),
        .package(url: "https://github.com/tuist/GraphViz", revision: "083bccf"),
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.23.1")),
        
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.0"),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.3.2"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/square/Cleanse", from: "4.2.6"),
        .package(url: "https://github.com/uber/needle", from: "0.24.0"),

//        .package(url: "https://github.com/TizianoCoroneo/Carpenter", from: "0.2.0"),
        .package(name: "Carpenter", path: "../Carpenter"),
        .package(name: "NeedleGenerator", path: "Generator"),
    ],
    targets: [
        .executableTarget(
            name: "ProfilerTarget",
            dependencies: [ 
                "ProjectGenerator",
                "Swinject",
                "Factory",
                "Cleanse",
                "Carpenter",
                .product(name: "NeedleFoundation", package: "needle"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
            resources: [ .process("project.spec") ],
            plugins: [
                .plugin(name: "GenerateProjectBuildPlugin"),
            ]),

        .executableTarget(
            name: "ProjectGeneratorCommands",
            dependencies: ["ProjectGenerator"]),

        .target(
            name: "ProjectGenerator",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "SwiftGraph",
                "SwiftWyhash",
                "GraphViz",
            ]),

        .testTarget(
            name: "ProjectGeneratorTests",
            dependencies: ["ProjectGenerator"]),

        .plugin(
            name: "GenerateProjectBuildPlugin",
            capability: .buildTool,
            dependencies: [
                "ProjectGeneratorCommands",
                .product(name: "needle", package: "NeedleGenerator"),
            ]),
    ]
)

// MARK: - Benchmarks

package.targets += [
    benchmark("CreateContainer"),
    benchmark("AccessAll"),
]

func benchmark(
    _ name: String,
    dependencies: [Target.Dependency] = [
        "Swinject",
        "Factory",
        "Cleanse",
        "Carpenter",
        .product(name: "NeedleFoundation", package: "needle"),
        .product(name: "Dependencies", package: "swift-dependencies"),
    ]
) -> Target {
    .executableTarget(
        name: name,
        dependencies: [ .product(name: "Benchmark", package: "package-benchmark") ] + dependencies,
        path: "Benchmarks/\(name)",
        resources: [ .process("project.spec") ],
        plugins: [
            .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            .plugin(name: "GenerateProjectBuildPlugin"),
        ]
    )
}
