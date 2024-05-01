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
        """
    }
}

public struct BasicTemplate: ProjectTemplate {
    let classes: [ClassTemplate]
    let graph: UnweightedGraph<Int>

    init(classes: [ClassTemplate], graph: UnweightedGraph<Int>) {
        self.classes = classes
        self.graph = graph
    }

    public init(graph: UnweightedGraph<Int>) {
        self.init(classes: ClassTemplate.from(graph: graph), graph: graph)
    }

    var definitions: String {
        """
        \(classes.map(\.definition).joined())

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
