
import Benchmark

#if DEBUG
private func commandClickToAccessBuiltCode() { print(SeeTheActualCode.self) }
#endif

let benchmarks = {
    Benchmark(
        "Simple",
        configuration: .init(maxDuration: .seconds(10))
    ) { benchmark in
        let template = SimpleTemplate()
        let c = template.makeContainer()

        benchmark.startMeasurement()

        for _ in benchmark.scaledIterations {
            blackHole(template.accessAllInContainer(c))
        }
    }

    Benchmark(
        "Swinject",
        configuration: .init(maxDuration: .seconds(10))
    ) { benchmark in
        let template = SwinjectTemplate()
        let c = template.makeContainer()

        benchmark.startMeasurement()

        for _ in benchmark.scaledIterations {
            blackHole(template.accessAllInContainer(c))
        }
    }

    Benchmark(
        "Factory",
        configuration: .init(maxDuration: .seconds(10))
    ) { benchmark in
        let template = FactoryTemplate()
        let c = template.makeContainer()

        benchmark.startMeasurement()

        for _ in benchmark.scaledIterations {
            blackHole(template.accessAllInContainer(c))
        }
    }
}
