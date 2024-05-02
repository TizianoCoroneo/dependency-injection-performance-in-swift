
import ArgumentParser
import SwiftGraph
import SwiftWyhash
import GraphViz
import Foundation

struct PropertyTemplate {
    let name: Int
    var assignment: String { "self.mock_\(name) = mock_\(name)" }
    var parameter: String { "mock_\(name): Mock_\(name)" }
    var passedParameter: String { "mock_\(name): mock_\(name)" }
    var declaration: String { "let mock_\(name): Mock_\(name)" }
}

struct ClassTemplate {
    let name: Int
    let properties: [PropertyTemplate]

    var propertyName: String {
        "mock_\(name)"
    }

    var typeName: String {
        "Mock_\(name)"
    }

    var typeObject: String {
        "\(typeName).self"
    }

    func constantInstanceDeclaration(level: Int) -> String {
        """
        let \(propertyName) = \(instance(level: level + 1))
        """
    }

    func instance(level: Int) -> String {
        """
        \(typeName)(\(indent(level, properties.map(\.passedParameter).joined(separator: ",\n"))))
        """
    }

    var containerPair: String {
        """
        ObjectIdentifier(\(typeObject)): \(propertyName) as Any
        """
    }

    var simpleAccess: String {
        """
        blackHole(container[ObjectIdentifier(\(typeObject))]! as! \(typeName))
        """
    }

    var definition: String {
        """
        public class \(typeName) { 
        \(indent(1, properties.map(\.declaration).joined(separator: "\n")))
            public init(
        \(indent(2, properties.map(\.parameter).joined(separator: ",\n")))
            ) {
        \(indent(2, properties.map(\.assignment).joined(separator: "\n")))
            }
        }

        """
    }

    static func from(graph: SwiftGraph.UnweightedGraph<Int>) -> [ClassTemplate] {
        let sortedVertices = graph.topologicalSort()!
        var classes: [ClassTemplate] = []

        for vertex in sortedVertices {
            let properties = (graph.neighborsForVertex(vertex) ?? [])
                .map { PropertyTemplate(name: $0) }

            let classTemplate = ClassTemplate(name: vertex, properties: properties)
            classes.append(classTemplate)
        }

        return classes
    }
}

public struct SimpleTemplate: ProjectTemplate {
    let classes: [ClassTemplate]

    init(classes: [ClassTemplate]) {
        self.classes = classes
    }

    public init(graph: UnweightedGraph<Int>) {
        self.init(classes: ClassTemplate.from(graph: graph))
    }

    public func contents(using rng: inout RandomNumberGenerator) -> String {
        """

        import func Benchmark.blackHole

        public struct GeneratedBySimple: GeneratedProject {
        public init() {}

        public typealias Container = [ObjectIdentifier: Any]

        public func makeContainer() -> Container { \(indent(1, classes.reversed().map { $0.constantInstanceDeclaration(level: 1) }.joined(separator: "\n")))
            return [\(indent(2, classes.map(\.containerPair).joined(separator: ",\n")))]
        }

        public func accessAllInContainer(_ container: Container) { \(indent(1, classes.shuffled(using: &rng).map(\.simpleAccess).joined(separator: "\n"))) }

        }

        """
    }
}
