
import ArgumentParser
import SwiftGraph
import SwiftWyhash
import Foundation
import ProjectGenerator

@main
struct GenerateSimpleProjectCommand: AsyncParsableCommand {

    @Option(transform: { try .init($0, format: .number, lenient: true) })
    var seed: UInt64 = .random(in: .min...(.max))

    @Option(completion: .file(extensions: ["spec"]), transform: readSpecFromArgument)
    var spec: GraphSpec

    @Option(completion: .file(extensions: ["swift"]), transform: URL.init(fileURLWithPath:))
    var simpleOut: URL
    @Option(completion: .file(extensions: ["swift"]), transform: URL.init(fileURLWithPath:))
    var swinjectOut: URL
    @Option(completion: .file(extensions: ["swift"]), transform: URL.init(fileURLWithPath:))
    var factoryOut: URL
    @Option(completion: .file(extensions: ["swift"]), transform: URL.init(fileURLWithPath:))
    var swiftDependenciesOut: URL
    @Option(completion: .file(extensions: ["swift"]), transform: URL.init(fileURLWithPath:))
    var cleanseOut: URL

    @Option(completion: .file(extensions: ["jpg"]), transform: URL.init(fileURLWithPath:))
    var imageOut: URL

    func run() async throws {
        var rng: any RandomNumberGenerator = WyRand(seed: spec.seed)
        let graph = UnweightedGraph.randomDAG(spec: spec, using: &rng)

        try BasicTemplate(graph: graph).contents(using: &rng).data(using: .utf8)?.write(to: simpleOut)

        try SwinjectTemplate(graph: graph).contents(using: &rng).data(using: .utf8)?.write(to: swinjectOut)

        try FactoryTemplate(graph: graph).contents(using: &rng).data(using: .utf8)?.write(to: factoryOut)

        try SwiftDependenciesTemplate(graph: graph).contents(using: &rng).data(using: .utf8)?.write(to: swiftDependenciesOut)

        try CleanseTemplate(graph: graph).contents(using: &rng).data(using: .utf8)?.write(to: cleanseOut)

        try await graph.renderToJPG().write(to: imageOut)
    }
}

private func readSpecFromArgument(_ argument: String) throws -> GraphSpec {
    let url = URL(filePath: argument, directoryHint: .checkFileSystem)
    return try JSONDecoder().decode(GraphSpec.self, from: Data(contentsOf: url))
}
