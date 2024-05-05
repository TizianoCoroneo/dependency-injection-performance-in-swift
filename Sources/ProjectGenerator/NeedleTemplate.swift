
import ArgumentParser
import SwiftGraph
import SwiftWyhash
import Foundation
import NeedleFoundation

public struct NeedleTemplate: ProjectTemplate {
    let classes: [ClassTemplate]

    init(classes: [ClassTemplate]) {
        self.classes = classes
    }

    public init(graph: UnweightedGraph<Int>) {
        self.init(classes: ClassTemplate.from(graph: graph))
    }

    class ContainerComponent: NeedleFoundation.BootstrapComponent {
        var mock_10: Int {
            shared { 1 }
        }
    }

    public func contents(using rng: inout any RandomNumberGenerator) -> String {
        """
        import NeedleFoundation
        import func Benchmark.blackHole

        public struct GeneratedByNeedle: GeneratedProject {
            public init() {}

            public class ContainerComponent: NeedleFoundation.BootstrapComponent {
        \(indent(1, classes.reversed().map(\.needleRegistration).joined(separator: "\n")))
            }

            public func makeContainer() -> ContainerComponent {
                registerProviderFactories()
                return ContainerComponent()
            }

            public func accessAllInContainer(_ container: ContainerComponent) {
        \(indent(1, classes.reversed().map(\.needleAccess).joined(separator: "\n")))
            }
        }

        """
    }
}

fileprivate extension ClassTemplate {
    var needleRegistration: String {
        """
        var \(propertyName): \(typeName) {
            shared { \(instance(level: 2)) }
        }
        """
    }

    var needleAccess: String {
        """
        blackHole(container.\(propertyName))
        """
    }
}
