
import ArgumentParser
import SwiftGraph
import Foundation
import ProjectGenerator

@main
struct GenerateSimpleProjectCommand: AsyncParsableCommand {

    @Option(transform: { try .init($0, format: .number, lenient: true) })
    var seed: UInt64 = .random(in: .min...(.max))

    @Option(completion: .file(extensions: ["spec"]), transform: readSpecFromArgument)
    var spec: GraphSpec

    @Option(completion: .file(extensions: ["swift"]), transform: URL.init(fileURLWithPath:))
    var sourceOut: URL

    @Option(completion: .file(extensions: ["jpg"]), transform: URL.init(fileURLWithPath:))
    var imageOut: URL

    func run() async throws {
        let graph = UnweightedGraph.randomDAG(spec: spec)

        let template: any ProjectTemplate = switch spec.projectType {
        case .simple: SimpleTemplate(graph: graph)
        case .swinject: SwinjectTemplate(graph: graph)
        }

        try template.contents.data(using: .utf8)?.write(to: sourceOut)
        try await graph.renderToJPG().write(to: imageOut)
    }
}

private func readSpecFromArgument(_ argument: String) throws -> GraphSpec {
    let url = URL(filePath: argument, directoryHint: .checkFileSystem)
    return try JSONDecoder().decode(GraphSpec.self, from: Data(contentsOf: url))
}
