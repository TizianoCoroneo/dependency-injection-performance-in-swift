
import Benchmark

#if DEBUG
private func commandClickToAccessBuiltCode() { print(SeeTheActualCode.self) }
#endif

let benchmarks = {
    Benchmark(
        "Simple",
        configuration: .init(maxDuration: .seconds(10))
    ) { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(SimpleTemplate().makeContainer())
        }
    }

    Benchmark(
        "Swinject",
        configuration: .init(maxDuration: .seconds(10))
    ) { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(SwinjectTemplate().makeContainer())
        }
    }

    Benchmark(
        "Factory",
        configuration: .init(maxDuration: .seconds(10))
    ) { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(FactoryTemplate().makeContainer())
        }
    }
}
