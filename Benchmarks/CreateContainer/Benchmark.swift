
import Benchmark

#if DEBUG
private func commandClickToAccessBuiltCode() { print(SeeTheActualCode.self) }
#endif

let benchmarks = {
    benchmark(name: "Simple", template: GeneratedBySimple())
    benchmark(name: "Swinject", template: GeneratedBySwinject())
    benchmark(name: "Factory", template: GeneratedByFactory())
    benchmark(name: "swift-dependencies", template: GeneratedBySwiftDependencies())
    benchmark(name: "Cleanse", template: GeneratedByCleanse())
    benchmark(name: "Needle", template: GeneratedByNeedle())
    benchmark(name: "Carpenter", template: GeneratedByCarpenter())
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
