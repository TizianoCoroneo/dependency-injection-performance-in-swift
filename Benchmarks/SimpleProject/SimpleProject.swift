// Benchmark boilerplate generated by Benchmark

import Benchmark
import Foundation

let benchmarks = {
    Benchmark("Simple") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(makeContainer())
        }
    }
}
