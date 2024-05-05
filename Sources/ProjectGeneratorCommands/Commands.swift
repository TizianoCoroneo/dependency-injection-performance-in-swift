
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
    @Option(completion: .file(extensions: ["swift"]), transform: URL.init(fileURLWithPath:))
    var needleOut: URL
    @Option(completion: .file(extensions: ["swift"]), transform: URL.init(fileURLWithPath:))
    var carpenterOut: URL

    @Option(completion: .file(extensions: ["jpg"]), transform: URL.init(fileURLWithPath:))
    var imageOut: URL

    func run() async throws {
        var rng: any RandomNumberGenerator = WyRand(seed: spec.seed)
        let graph = UnweightedGraph.randomDAG(spec: spec, using: &rng)

        let templates: [((UnweightedGraph<Int>) -> any ProjectTemplate, URL)] = [
            (SimpleTemplate.init(graph:), simpleOut),
            (SwinjectTemplate.init(graph:), swinjectOut),
            (FactoryTemplate.init(graph:), factoryOut),
            (SwiftDependenciesTemplate.init(graph:), swiftDependenciesOut),
            (CleanseTemplate.init(graph:), cleanseOut),
            (NeedleTemplate.init(graph:), needleOut),
            (CarpenterTemplate.init(graph:), carpenterOut),
        ]

        for (makeTemplate, outputURL) in templates {
            try makeTemplate(graph).contents(using: &rng).data(using: .utf8)?.write(to: outputURL)
        }

        try await graph.renderToJPG().write(to: imageOut)
    }
}

private func readSpecFromArgument(_ argument: String) throws -> GraphSpec {
    let url = URL(filePath: argument, directoryHint: .checkFileSystem)
    return try JSONDecoder().decode(GraphSpec.self, from: Data(contentsOf: url))
}
