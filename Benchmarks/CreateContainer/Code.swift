
import Benchmark

#if DEBUG
private func commandClickToAccessBuiltCode() { print(SeeTheActualCode.self) }
#endif

let benchmarks = {
    benchmark(name: "Simple", template: GeneratedBySimple())
    benchmark(name: "Swinject", template: GeneratedBySwinject())
    benchmark(name: "Factory", template: GeneratedByFactory())
    benchmark(name: "swift-dependencies", template: GeneratedBySwiftDependencies())
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
            blackHole(template.makeContainer())
        }
    }
}
