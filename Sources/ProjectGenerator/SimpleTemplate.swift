
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

    func constantInstanceDeclaration(level: Int) -> String {
        """
        let mock_\(name) = \(instance(level: level + 1))
        """
    }

    func instance(level: Int) -> String {
        """
        Mock_\(name)(\(indent(level, properties.map(\.passedParameter), separator: ",")))
        """
    }

    var containerPair: String {
        """
        ObjectIdentifier(Mock_\(name).self): mock_\(name) as Any
        """
    }

    var simpleAccess: String {
        """
        blackHole(container[ObjectIdentifier(Mock_\(name).self)]! as! Mock_\(name))
        """
    }

    var definition: String {
        """
        public class Mock_\(name) { \(indent(1, properties.map(\.declaration)))
            public init(\(indent(2, properties.map(\.parameter), separator: ","))) {\(indent(2, properties.map(\.assignment)))}
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

    var definitions: String {
        """
        \(classes.map(\.definition).joined())

        """
    }

    public func contents(using rng: inout RandomNumberGenerator) -> String {
        """
        \(definitions)

        public typealias Container = [ObjectIdentifier: Any]

        public func makeContainer() -> Container { \(indent(1, classes.reversed().map { $0.constantInstanceDeclaration(level: 1) }))
            return [\(indent(2, classes.map(\.containerPair), separator: ","))]
        }

        public func accessAllInContainer(_ container: Container) { \(indent(1, classes.shuffled(using: &rng).map(\.simpleAccess))) }

        @_optimize(none) private func blackHole(_: some Any) {}

        """
    }
}
