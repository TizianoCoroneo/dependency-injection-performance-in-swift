// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "dependency-injection-performance",
    platforms: [
        .macOS(.v13),
        .iOS("999")
    ],
    products: [
        .executable(name: "ProjectGeneratorCommands", targets: ["ProjectGeneratorCommands"]),
        .plugin(name: "GenerateProjectBuildPlugin", targets: ["GenerateProjectBuildPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/davecom/SwiftGraph", from: "3.1.0"),
        .package(url: "https://github.com/lemire/SwiftWyhash", from: "0.1.1"),
        .package(url: "https://github.com/SwiftDocOrg/GraphViz", from: "0.4.1"),
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.23.1")),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.0"),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.3.2"),
    ],
    targets: [
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
                "Swinject",
                "Factory",
            ]),
        
        .testTarget(
            name: "ProjectGeneratorTests",
            dependencies: ["ProjectGenerator"]),

        .plugin(
            name: "GenerateProjectBuildPlugin",
            capability: .buildTool,
            dependencies: ["ProjectGeneratorCommands"]),
    ]
)

// MARK: - Benchmarks

package.targets += [
    benchmark("SimpleProject"),
    benchmark("SwinjectProject", dependencies: ["Swinject"]),
    benchmark("FactoryProject", dependencies: ["Factory"]),
]

func benchmark(_ name: String, dependencies: [Target.Dependency] = []) -> Target {
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