
import ArgumentParser
import SwiftGraph
import SwiftWyhash
import GraphViz
import Foundation

public struct CleanseTemplate: ProjectTemplate {
    let classes: [ClassTemplate]
    let sourceClasses: [ClassTemplate]

    init(
        classes: [ClassTemplate],
        sourceClasses: [ClassTemplate]
    ) {
        self.classes = classes
        self.sourceClasses = sourceClasses
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
            sourceClasses: sourceVertices.map { ClassTemplate(name: $0) })
    }

    public func contents(using rng: inout any RandomNumberGenerator) -> String {
        """
        import Cleanse
        import func Benchmark.blackHole

        public struct GeneratedByCleanse: GeneratedProject {
        public init() {}

        public struct BenchmarkComponent : Cleanse.RootComponent {
            public typealias Root = BuiltProductsContainer

            public static func configureRoot(binder: ReceiptBinder<BuiltProductsContainer>) -> BindingReceipt<BuiltProductsContainer> {
                binder.to(factory: BuiltProductsContainer.init)
            }

            public static func configure(binder: Binder<Singleton>) {
        \(indent(3, classes.map(\.cleanseRegistration).joined(separator: "\n")))
            }
        }

        public func makeContainer() -> ComponentFactory<ComponentFactory<BenchmarkComponent>.ComponentElement> {
            try! ComponentFactory.of(BenchmarkComponent.self)
        }

        public func accessAllInContainer(_ container: ComponentFactory<ComponentFactory<BenchmarkComponent>.ComponentElement>) {
            blackHole(container.build(()))
        }
        
        }

        """
    }
}

fileprivate extension ClassTemplate {
    var cleanseRegistration: String {
        """
        binder
            .bind(\(typeObject))
            .sharedInScope()
            .to(factory: \(typeName).init)
        """
    }

    var cleanseAccess: String {
        """
        blackHole( container.\(propertyName))
        """
    }
}
