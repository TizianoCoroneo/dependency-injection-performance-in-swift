//
//  ProjectTemplate.swift
//  
//
//  Created by Tiziano Coroneo on 30/04/2024.
//

import SwiftGraph

public protocol ProjectTemplate {
    init(graph: UnweightedGraph<Int>)

    func contents(using rng: inout RandomNumberGenerator) -> String
}

public extension ProjectTemplate {
    var boilerplate: String {
        """
        import func Benchmark.blackHole

        public enum SeeTheActualCode {}
        
        protocol GeneratedProject {
            associatedtype Container
            func makeContainer() -> Container
            func accessAllInContainer(_ container: Container)
        }
        """
    }
}

public struct BasicTemplate: ProjectTemplate {
    let classes: [ClassTemplate]
    let sourceClasses: [ClassTemplate]
    let graph: UnweightedGraph<Int>

    init(
        classes: [ClassTemplate],
        sourceClasses: [ClassTemplate],
        graph: UnweightedGraph<Int>
    ) {
        self.classes = classes
        self.sourceClasses = sourceClasses
        self.graph = graph
    }

    public init(graph: UnweightedGraph<Int>) {
        let sourceVertices = graph.indices.compactMap { index in
            if graph.indegreeOfVertex(at: index) == 0 {
                return graph.vertexAtIndex(index)
            } else {
                return nil
            }
        }

        self.init(
            classes: ClassTemplate.from(graph: graph),
            sourceClasses: sourceVertices.map { ClassTemplate(name: $0) },
            graph: graph)
    }

    var definitions: String {
        """
        \(classes.map(\.definition).joined())

        public class BuiltProductsContainer {
        \(indent(1, sourceClasses.map(\.declaration).joined(separator: "\n")))
            public init(
        \(indent(2, sourceClasses.map(\.parameter).joined(separator: ",\n")))
            ) {
        \(indent(2, sourceClasses.map(\.assignment).joined(separator: "\n")))
            }
        }

        """
    }

    public func contents(using rng: inout any RandomNumberGenerator) -> String {
        """
        \(boilerplate)

        \(definitions)

        \(SimpleTemplate(graph: graph).contents(using: &rng))

        """
    }
}
