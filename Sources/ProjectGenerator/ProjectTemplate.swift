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
        import Benchmark

        public enum SeeTheActualCode {}

        let benchmarks = {
            Benchmark(
                "\(Self.self) - Create container",
                configuration: .init(maxDuration: .seconds(10))
            ) { benchmark in
                for _ in benchmark.scaledIterations {
                    blackHole(makeContainer())
                }
            }

            Benchmark(
                "\(Self.self) - Read all from container",
                configuration: .init(maxDuration: .seconds(10))
            ) { benchmark in
                let c = makeContainer()

                benchmark.startMeasurement()
                for _ in benchmark.scaledIterations {
                    accessAllInContainer(c)
                }
            }
        }

        """
    }
}
