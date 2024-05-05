
import ArgumentParser
import SwiftGraph
import SwiftWyhash
import Foundation

public struct SwinjectTemplate: ProjectTemplate {
    let classes: [ClassTemplate]

    init(classes: [ClassTemplate]) {
        self.classes = classes
    }

    public init(graph: UnweightedGraph<Int>) {
        self.init(classes: ClassTemplate.from(graph: graph))
    }

    public func contents(using rng: inout any RandomNumberGenerator) -> String {
        """
        import Swinject
        import func Benchmark.blackHole

        public struct GeneratedBySwinject: GeneratedProject {
            public init() {}

            public func makeContainer() -> Container {
                let container = Container()

        \(indent(2, classes.reversed().map(\.swinjectRegistration).joined(separator: "\n")))

                return container
            }

            public func accessAllInContainer(_ container: Container) {
        \(indent(2, classes.reversed().map(\.swinjectAccess).joined(separator: "\n")))
            }
        }

        """
    }
}

fileprivate extension ClassTemplate {
    var swinjectDependency: String {
        """
        mock_\(name): r.resolve(Mock_\(name).self)!
        """
    }

    var swinjectRegistration: String {
        """
        container.register(Mock_\(name).self) { r in Mock_\(name).init(\(indent(2, properties.map(\.swinjectDependency).joined(separator: ",\n")))) }
            .inObjectScope(.container)
        """
    }

    var swinjectAccess: String {
        """
        blackHole(container.resolve(Mock_\(name).self)!)
        """
    }
}
