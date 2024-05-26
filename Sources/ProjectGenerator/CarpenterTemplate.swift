
import ArgumentParser
import SwiftGraph
import SwiftWyhash
import Foundation

public struct CarpenterTemplate: ProjectTemplate {
    let classes: [ClassTemplate]

    init(classes: [ClassTemplate]) {
        self.classes = classes
    }

    public init(graph: SwiftGraph.UnweightedGraph<Int>) {
        self.init(classes: ClassTemplate.from(graph: graph))
    }

    public func contents(using rng: inout any RandomNumberGenerator) -> String {
        """
        import Carpenter

        public final class CarpenterContainer: DependencyContainer {
            public static var shared: CarpenterContainer = .init()
            public init() {}

        \(indent(1, classes.reversed().map(\.carpenterRegistration).joined(separator: "\n")))
        }

        public struct GeneratedByCarpenter: GeneratedProject {
            public init() {}

            public func makeContainer() -> Carpenter {
                var c = try! Carpenter.init {
        \(indent(3, classes.reversed().map(\.carpenterInsertIntoContainer).joined(separator: "\n")))
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

    var carpenterInsertIntoContainer: String {
        """
        CarpenterContainer.shared.\(propertyName)
        """
    }

    var carpenterAccess: String {
        """
        blackHole(GetDependency(carpenter: container, \\CarpenterContainer.\(propertyName)).wrappedValue)
        """
    }
}
