//
//  Utilities.swift
//
//
//  Created by Tiziano Coroneo on 30/04/2024.
//

import ArgumentParser
import SwiftGraph
import SwiftWyhash
import GraphViz
import Foundation

func indent(_ level: Int, _ content: String) -> String {
    let splits = content.split(separator: "\n")
    let level = splits.isEmpty ? 0 : level
    return splits
        .map { "\(String(repeating: "    ", count: level))\($0)" }
        .joined(separator: "\n")
}

extension GraphViz.Graph {
    init(_ swiftGraph: SwiftGraph.UnweightedGraph<Int>) {
        self.init(directed: true, strict: true)

        append(contentsOf: swiftGraph.vertices
            .map { GraphViz.Node("Mock_\($0)") })

        append(contentsOf: swiftGraph.edgeList()
            .map { GraphViz.Edge(from: "Mock_\($0.u)", to: "Mock_\($0.v)") })
    }
}

public struct GraphSpec: Codable {
    let width: ClosedRange<Int>
    let height: ClosedRange<Int>
    let density: Double
    public let seed: UInt64

    public init(width: ClosedRange<Int>, height: ClosedRange<Int>, density: Double, seed: UInt64 = 0) {
        self.width = width
        self.height = height
        self.density = density
        self.seed = seed
    }
}

extension UnweightedGraph<Int> {
    public static func randomDAG(
        spec: GraphSpec,
        using rng: inout RandomNumberGenerator
    ) -> UnweightedGraph<Int> {
        randomDAG(
            widthRange: spec.width,
            heightRange: spec.height,
            density: spec.density,
            using: &rng)
    }

    internal static func randomDAG(
        widthRange: ClosedRange<Int> = 1...10, // Nodes/Rank: How 'fat' the DAG should be
        heightRange: ClosedRange<Int> = 15...20, // Ranks: How 'tall' the DAG should be
        density: Double = 0.8,
        using randomGenerator: inout RandomNumberGenerator
    ) -> UnweightedGraph<Int> {
        var nodes = 0
        var node_counter = 0

        let ranks = Int.random(in: heightRange, using: &randomGenerator)

        let graph = UnweightedGraph<Int>()
        var rank_list = [[Int]]()

        for i in 0..<ranks {
            let new_nodes = Int.random(in: widthRange, using: &randomGenerator)

            var list = [Int]()
            for _ in 0..<new_nodes {
                let nodeID = node_counter
                node_counter += 1
                list.append(nodeID)
                _ = graph.addVertex(nodeID)
            }

            rank_list.append(list)

            if i > 0 {
                for oldNodeId in rank_list[i - 1] {
                    for newNodeId in 0..<new_nodes
                    where Double.random(in: 0...1, using: &randomGenerator) <= density {
                        graph.addEdge(from: oldNodeId, to: newNodeId + nodes, directed: true)
                    }
                }
            }

            nodes += new_nodes
        }

        return graph
    }
}

public extension UnweightedGraph<Int> {
    func renderToJPG() async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            Renderer(layout: .dot).render(
                graph: .init(self),
                to: .jpeg,
                completion: continuation.resume(with:))
        }
    }
}
