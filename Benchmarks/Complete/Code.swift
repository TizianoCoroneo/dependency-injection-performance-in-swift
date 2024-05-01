
import Benchmark

#if DEBUG
private func commandClickToAccessBuiltCode() { print(SeeTheActualCode.self) }
#endif

let benchmarks = {
    benchmark(name: "Simple", template: SimpleTemplate())
    benchmark(name: "Swinject", template: SwinjectTemplate())
    benchmark(name: "Factory", template: FactoryTemplate())
    benchmark(name: "swift-dependencies", template: SwiftDependenciesTemplate())
}

func benchmark<P: GeneratedProject>(
    name: String,
    template: P
) {
    Benchmark(
        name,
        configuration: .init(maxDuration: .seconds(10))
    ) { benchmark in
        for _ in benchmark.scaledIterations {
            let c = template.makeContainer()
            blackHole(template.accessAllInContainer(c))
        }
    }
}
