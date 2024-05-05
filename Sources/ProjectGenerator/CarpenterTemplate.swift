
import ArgumentParser
import SwiftGraph
import SwiftWyhash
import Foundation
import Carpenter

public struct CarpenterTemplate: ProjectTemplate {
    let classes: [ClassTemplate]

    init(classes: [ClassTemplate]) {
        self.classes = classes
    }

    public init(graph: UnweightedGraph<Int>) {
        self.init(classes: ClassTemplate.from(graph: graph))
    }

    public func contents(using rng: inout any RandomNumberGenerator) -> String {
        """
        import Carpenter
        import func Benchmark.blackHole

        public final class CarpenterContainer: DependencyContainer {
            public static var shared: CarpenterContainer = .init()
            public init() {}

        \(indent(1, classes.reversed().map(\.carpenterRegistration).joined(separator: "\n")))
        }

        public struct GeneratedByCarpenter: GeneratedProject {
            public init() {}

            public func makeContainer() -> Carpenter {
                var c = try! Carpenter.init {
                    CarpenterContainer.allFactories
                }

                try! c.build()

                return c
            }

            public func accessAllInContainer(_ container: Carpenter) {
        \(indent(2, classes.reversed().map(\.carpenterAccess).joined(separator: "\n")))
            }
        }
        """
    }
}

fileprivate extension ClassTemplate {

    var carpenterRegistration: String {
        """
        let \(propertyName) = Factory(\(typeName).init)
        """
    }

    var carpenterAccess: String {
        """
        blackHole(GetDependency(carpenter: container, \\CarpenterContainer.\(propertyName)).wrappedValue)
        """
    }
}
