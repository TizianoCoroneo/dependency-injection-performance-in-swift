
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

    var constantInstanceDeclaration: String {
        """
        let mock_\(name) = \(instance)

        """
    }

    var instance: String {
        """
        Mock_\(name)(\(indent(1, properties.map(\.passedParameter), separator: ",")))
        """
    }

    var containerPair: String {
        """
        ObjectIdentifier(Mock_\(name).self): mock_\(name) as Any
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

    public var contents: String {
        """
        \(definitions)

        public func makeContainer() -> [ObjectIdentifier: Any] { \(indent(1, classes.reversed().map(\.constantInstanceDeclaration)))
            return [\(indent(2, classes.map(\.containerPair), separator: ","))]
        }

        """
    }
}
